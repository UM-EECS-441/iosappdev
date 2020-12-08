from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
from datetime import datetime
import json
import operator
import math
import googlemaps

# This is a class to store basic driver information. 
# It is used in getclosestdriver and the functions in this class are used to sort the list of Driver_info objects
class Driver_info:
    def __init__(self):
        self.username = '' 
        self.first_name = ''
        self.last_name = ''
        self.profile = ''
        self.car = ''
        self.rating = ''
        self.latitude = 0
        self.longitude = 0
        self.distance = 0
        self.distance_text = ''
        self.duration_text = ''
        self.duration_value = 0
        self.distance_value = 0
        self.current_address = ''
    
    def get_distance(self):
        return self.distance

    def get_duration(self):
        return self.duration_value

# API Function to get all drivers from the database along with all other information 
def getdrivers(request):
    if request.method != 'GET':
        return HttpResponse(status=404)

    cursor = connection.cursor()
    cursor.execute('SELECT * FROM drivers;')
    rows = cursor.fetchall()

    response = {}
    response['drivers'] = rows
    return JsonResponse(response)

# converts from seconds to an hours, minutes and seconds format
def convertTime(seconds): 
    seconds = seconds % (24 * 3600) 
    hour = seconds // 3600
    seconds %= 3600
    minutes = seconds // 60
    seconds %= 60
    result = str(hour) + ' hours ' + str(minutes) + ' minutes ' + str(seconds) + ' seconds'
    return result

# converts from meters to miles
def convertDistance(meters):
    km = meters/1000
    # conversion factor
    conv_fac = 0.621371

    # calculate miles
    miles = km * conv_fac
    result_miles = format(miles, '.2f')
    result = str(result_miles) + ' miles'
    return result

# helper function that takes in origin coordinates and destination coordinates
# returns the duration and distance between these two points using the google maps API
def durationDistance(origin_lat, origin_lon, destination_lat, destination_lon):
    gmaps = googlemaps.Client(key='AIzaSyCnpaIHR9YUqjRX3RxutTaKALh4E6qLbFQ')
    origins = [] 
    destinations = []
    origins.append(str(origin_lat) + ' ' + str(origin_lon))
    destinations.append(str(destination_lat) + ' ' + str(destination_lon))
    matrix = (gmaps.distance_matrix(origins, destinations, mode="driving"))["rows"][0]["elements"][0]
    duration_and_distance = {
                                "duration": matrix["duration"]["value"],
                                "distance": matrix["distance"]["value"]
                            }
    return duration_and_distance

# helper function that checks if the unassigned user is within 3km
# of any of the assigned users to that driver when there are atleast 5 assigned users
# If within that range this function returns true, else returns false
# If the driver does not have atleast 5 assigned customers range is not considered 
def is_within_range(driver_username, customer_latitude, customer_longitude):
    gmaps = googlemaps.Client(key='AIzaSyCnpaIHR9YUqjRX3RxutTaKALh4E6qLbFQ')
    cursor = connection.cursor()
    cursor.execute(f"SELECT COUNT(*) FROM customers WHERE driver_username = '{driver_username}'")
    num_current_customers = cursor.fetchone()[0]
    # Check if the driver has atleast 5 assigned customers 
    if num_current_customers <= 5:
        return True

    # get latitude and longitude for all assigned customers
    cursor.execute(f"SELECT customer_latitude, customer_longitude FROM customers WHERE driver_username = '{driver_username}'")
    current_customers_info = cursor.fetchall()
    distance_values = []
    # destinations = unassigned user location, origins = list of locations of all assigned users
    for current_customer in current_customers_info:
        distance_values.append(durationDistance(current_customer[0], current_customer[1], customer_latitude, customer_longitude)["distance"])

    # if any distance is less than 3km, unassigned user is within range and therefore return true
    if min(distance_values) < 3000:
        return True
    return False


# optimal route function that calculates distances between assigned users to determine optimal delivery path
# up until 3 concurrent customers use brute force, then we use the nearest neighbors heuristic
def optRoute(driver_username):
    # update the database with the optimal route 
    # Fetch necessary info
    gmaps = googlemaps.Client(key='AIzaSyCnpaIHR9YUqjRX3RxutTaKALh4E6qLbFQ')
    cursor = connection.cursor()
    cursor.execute(f"SELECT COUNT(*) FROM customers WHERE driver_username = '{driver_username}'")
    num_current_customers = cursor.fetchone()[0]
    cursor.execute(f"SELECT pharm_lat, pharm_lon FROM drivers WHERE drivers.username = '{driver_username}'")
    locations = cursor.fetchone()
    # acquire pharmacy coordinates
    pharmacy_lat = locations[0]
    pharmacy_lon = locations[1]
    # get optimal route for more than 3 users usinng nearest neighbour heuristic
    if num_current_customers > 3:
        nearestNeighbors(driver_username, pharmacy_lat, pharmacy_lon)
        return
    # Get customer info
    cursor.execute(f"SELECT * FROM customers WHERE driver_username = '{driver_username}'")
    current_customers_info = cursor.fetchall()
    user1 = current_customers_info[0][1]
    user1_lat = current_customers_info[0][2]
    user1_lon = current_customers_info[0][3]
    
    
    customers_queue = []
    origins = [] 
    destinations = []
    # For up to 3 users, find optimal route by calculating every possible path to find minimal one
    # if 1 customer (basic order of delivery)
    if num_current_customers == 1:
        cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
        return
    # if 2 customers
    elif num_current_customers == 2:
        user2_lat = current_customers_info[1][2]
        user2_lon = current_customers_info[1][3]
        user2 = current_customers_info[1][1]
        # distance from pharmacy to user1 to user2
        origins.append(str(pharmacy_lat) + ' ' + str(pharmacy_lon))
        destinations.append(str(user1_lat) + ' ' + str(user1_lon))
        matrix_1 = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrompharmto1 = matrix_1["rows"][0]["elements"][0]["duration"]["value"]
        origins = [] 
        destinations = []
        origins.append(str(user1_lat) + ' ' + str(user1_lon))
        destinations.append(str(user2_lat) + ' ' + str(user2_lon))
        matrix_1 = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrom1to2 = matrix_1["rows"][0]["elements"][0]["duration"]["value"]
        option_1_duration = durationfrompharmto1 + durationfrom1to2

        # distance from pharmacy to user2 to user1
        origins = [] 
        destinations = []
        origins.append(str(pharmacy_lat) + ' ' + str(pharmacy_lon))
        destinations.append(str(user2_lat) + ' ' + str(user2_lon))
        matrix_2 = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrompharmto2 = matrix_2["rows"][0]["elements"][0]["duration"]["value"]
        origins = [] 
        destinations = []
        origins.append(str(user2_lat) + ' ' + str(user2_lon))
        destinations.append(str(user1_lat) + ' ' + str(user1_lon))
        matrix_2 = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrom2to1 = matrix_2["rows"][0]["elements"][0]["duration"]["value"]
        option_2_duration = durationfrompharmto2 + durationfrom2to1
        # compare the two paths and select one with lower total duration
        if (option_2_duration < option_1_duration):
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
        if (option_2_duration >= option_1_duration):
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")


    #if 3 customers
    else:
        user2_lat = current_customers_info[1][2]
        user2_lon = current_customers_info[1][3]
        user3_lat = current_customers_info[2][2]
        user3_lon = current_customers_info[2][3]
        user2 = current_customers_info[1][1]
        user3 = current_customers_info[2][1]
        # pharmacy to users 1,2,3
        origins.append(str(pharmacy_lat) + ' ' + str(pharmacy_lon))
        destinations.append(str(user1_lat) + ' ' + str(user1_lon))
        destinations.append(str(user2_lat) + ' ' + str(user2_lon))
        destinations.append(str(user3_lat) + ' ' + str(user3_lon))
        matrix = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrompharmto1 = matrix["rows"][0]["elements"][0]["duration"]["value"]
        durationfrompharmto2 = matrix["rows"][0]["elements"][1]["duration"]["value"]
        durationfrompharmto3 = matrix["rows"][0]["elements"][2]["duration"]["value"]

        # user 1 to users 2,3
        origins = []
        destinations = []
        origins.append(str(user1_lat) + ' ' + str(user1_lon))
        destinations.append(str(user2_lat) + ' ' + str(user2_lon))
        destinations.append(str(user3_lat) + ' ' + str(user3_lon))
        matrix = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrom1to2 = matrix["rows"][0]["elements"][0]["duration"]["value"]
        durationfrom1to3 = matrix["rows"][0]["elements"][1]["duration"]["value"]

        # user 2 to users 1,3
        origins = []
        destinations = []
        origins.append(str(user2_lat) + ' ' + str(user2_lon))
        destinations.append(str(user1_lat) + ' ' + str(user1_lon))
        destinations.append(str(user3_lat) + ' ' + str(user3_lon))
        matrix = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrom2to1 = matrix["rows"][0]["elements"][0]["duration"]["value"]
        durationfrom2to3 = matrix["rows"][0]["elements"][1]["duration"]["value"]
        
        # user 3 to users 1,2
        origins =[]
        destinations = []
        origins.append(str(user3_lat) + ' ' + str(user3_lon))
        destinations.append(str(user1_lat) + ' ' + str(user1_lon))
        destinations.append(str(user2_lat) + ' ' + str(user2_lon))
        matrix = gmaps.distance_matrix(origins, destinations, mode="driving")
        durationfrom3to1 = matrix["rows"][0]["elements"][0]["duration"]["value"]
        durationfrom3to2 = matrix["rows"][0]["elements"][1]["duration"]["value"]
        
        options = []
        # distance from pharm to 1 to 2 to 3
        options.append(durationfrompharmto1 + durationfrom1to2 + durationfrom2to3)

        # distance from pharm to 1 to 3 to 2
        options.append(durationfrompharmto1 + durationfrom1to3 + durationfrom3to2)

        # distance from pharm to 2 to 1 to 3
        options.append(durationfrompharmto2 + durationfrom2to1 + durationfrom1to3)

        # distance from pharm to 2 to 3 to 1 
        options.append(durationfrompharmto2 + durationfrom2to3 + durationfrom3to1)

        # distance from pharm to 3 to 1 to 2
        options.append(durationfrompharmto3 + durationfrom3to1 + durationfrom1to2)

        # distance from pharm to 3 to 2 to 1
        options.append(durationfrompharmto3 + durationfrom3to2 + durationfrom2to1)

        opt_option = options.index(min(options))

        if (opt_option == 1):# distance from pharm to 1 to 3 to 2
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {3} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user3}' and driver_username = '{driver_username}' ")
        elif (opt_option == 2):# distance from pharm to 2 to 1 to 3
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {3} WHERE customer_username = '{user3}' and driver_username = '{driver_username}' ")
        elif (opt_option == 3):# distance from pharm to 2 to 3 to 1
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {3} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user3}' and driver_username = '{driver_username}' ")
        elif (opt_option == 4):# distance from pharm to 3 to 1 to 2
            cursor.execute(f"UPDATE customers SET delivery_order = {3} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user3}' and driver_username = '{driver_username}' ")
        elif (opt_option == 5):# distance from pharm to 3 to 2 to 1v
            cursor.execute(f"UPDATE customers SET delivery_order = {3} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user3}' and driver_username = '{driver_username}' ")
        else:# distance from pharm to 1 to 2 to 3
            cursor.execute(f"UPDATE customers SET delivery_order = {1} WHERE customer_username = '{user1}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {2} WHERE customer_username = '{user2}' and driver_username = '{driver_username}' ")
            cursor.execute(f"UPDATE customers SET delivery_order = {3} WHERE customer_username = '{user3}' and driver_username = '{driver_username}' ")



def nearestNeighbors(driver_username, pharmacy_lat, pharmacy_lon):
    # if more than 3 concurrent customers use "nearest neighbour" heuristic to determine best route between new added users
    cursor = connection.cursor()
    cursor.execute(f"SELECT customer_username, customer_latitude, customer_longitude FROM customers WHERE driver_username = '{driver_username}'")
    customer_list = cursor.fetchall()

    current_username = "pharmacy"
    current_latitude = pharmacy_lat
    current_longitude = pharmacy_lon
    curr_order = 1
    while len(customer_list) > 0:
        durations = []
        # find minimum duration index of all customers to curr
        for customers in customer_list:
            # append every duration from curr to customers to a duration list
            durations.append(durationDistance(current_latitude, current_longitude, customers[1], customers[2])["duration"])
        
        min_duration_index = durations.index(min(durations))
        #  once we find minimum duration/customer index, update database, and make it the new curr
        current_username = customer_list[min_duration_index][0]
        current_latitude = customer_list[min_duration_index][1]
        current_longitude = customer_list[min_duration_index][2]

        cursor.execute(f"UPDATE customers SET delivery_order = {curr_order} WHERE customer_username = '{current_username}' and driver_username = '{driver_username}' ")
        curr_order += 1
        #remove minimal option from list to continue to next choice
        customer_list.remove(customer_list[min_duration_index])
                
                

@csrf_exempt
def getclosestdriver(request, username, lat, lon, username_lat, username_lon):
    # Gets the closest driver from the customer's selected pharmacy. Assigns same driver to up to 3 users without range restrictions
    # If adding more customers to the driver after 3rd one, the next customer must be within 3000m (~2m)
    if request.method != 'GET':
        return HttpResponse(status=404)
    
    gmaps = googlemaps.Client(key='AIzaSyCnpaIHR9YUqjRX3RxutTaKALh4E6qLbFQ')
    origins = []
    destinations = []
    driver_info = []
    closest_drivers = []
    pharmacyLat = float(lat)
    pharmacyLon = float(lon)     
    cursor = connection.cursor()
    cursor.execute('SELECT * FROM drivers;')
    rows = cursor.fetchall()
    for row in rows:
        driver = Driver_info()
        driver.username = row[0]
        driver.latitude = float(row[1])
        driver.longitude = float(row[2])
        driver.car = row[3]
        driver.rating = row[4]
        driver.profile = row[5]
        driver.first_name = row[7]
        driver.last_name = row[8]
        origins.append(row[1] + ' ' + row[2])
        driver_info.append(driver)
    destinations.append(str(pharmacyLat) + ' ' + str(pharmacyLon))
    matrix = gmaps.distance_matrix(origins, destinations, mode="driving")
    for count, info in enumerate(matrix['rows']):
        driver = Driver_info()
        driver.username = driver_info[count].username
        driver.latitude = driver_info[count].latitude
        driver.longitude = driver_info[count].longitude
        driver.first_name = driver_info[count].first_name
        driver.last_name = driver_info[count].last_name
        driver.profile = driver_info[count].profile
        driver.car = driver_info[count].car
        driver.rating = driver_info[count].rating
        driver.distance_text = info["elements"][0]["distance"]["text"]
        driver.duration_text = info["elements"][0]["duration"]["text"]
        driver.duration_value = info["elements"][0]["duration"]["value"]
        driver.distance_value = info["elements"][0]["distance"]["value"]
        driver.current_address = matrix["origin_addresses"][count]
        closest_drivers.append(driver)
    closest_drivers.sort(key=lambda b: b.get_duration()) 
    index = 0
    loop = True
    while loop:
        closest_driver = {
                        "username": closest_drivers[index].username,
                        "first_name": closest_drivers[index].first_name,
                        "last_name": closest_drivers[index].last_name,
                        "profile": closest_drivers[index].profile,
                        "distance": closest_drivers[index].distance_text,
                        "duration": closest_drivers[index].duration_text,
                        "location": closest_drivers[index].current_address,
                        "latitude": closest_drivers[index].latitude,
                        "longitude": closest_drivers[index].longitude,
                        "car": closest_drivers[index].car,
                        "rating": closest_drivers[index].rating
                        }
        cursor = connection.cursor()
        cursor.execute(f"SELECT status FROM drivers WHERE drivers.username = '{closest_drivers[index].username}'")
        current_status = cursor.fetchone()[0]
        
        if current_status == "user":
            index += 1
            continue
        
        elif current_status == "pharmacy":
            cursor.execute(f"SELECT pharm_lat, pharm_lon FROM drivers WHERE username = '{closest_drivers[index].username}'")
            past_pharm = cursor.fetchone()
            if not (past_pharm[0] == pharmacyLat and past_pharm[1] == pharmacyLon):
                index += 1
                continue
            if not is_within_range(closest_drivers[index].username, username_lat, username_lon):
                index += 1
                continue
            # closest_driver["range"] = is_within_range(closest_drivers[index].username, username_lat, username_lon)
            
        cursor.execute('INSERT INTO customers (driver_username, customer_username, customer_latitude, customer_longitude, delivery_order) VALUES '
                    '(%s, %s, %s, %s, %s);', (closest_drivers[index].username, username, username_lat, username_lon, int(0)))
        cursor.execute(f"UPDATE drivers SET status = 'pharmacy', pharm_lat = {pharmacyLat}, pharm_lon = {pharmacyLon} WHERE username = '{closest_drivers[index].username}'")
        loop = False    
        
    values = []
    optRoute(closest_driver["username"])
    values = getEta(username, closest_driver["username"])
    closest_driver["ETA"] = values[0]
    closest_driver["distance"] = values[1]
    return JsonResponse(closest_driver)


def getEta(username, driver_username):
    gmaps = googlemaps.Client(key='AIzaSyCnpaIHR9YUqjRX3RxutTaKALh4E6qLbFQ')
    cursor = connection.cursor()
    cursor.execute(f"SELECT delivery_order FROM customers WHERE driver_username = '{driver_username}' and customer_username = '{username}'")
    delivery_order = cursor.fetchone()[0]
    cursor.execute(f"SELECT * FROM customers WHERE driver_username = '{driver_username}' ORDER BY delivery_order")
    deliveries = cursor.fetchmany(delivery_order)
    cursor.execute(f"SELECT latitude, longitude FROM drivers WHERE username = '{driver_username}'")
    driver_origin = cursor.fetchone()
    cursor.execute(f"SELECT pharm_lat, pharm_lon FROM drivers WHERE username = '{driver_username}'")
    pharmacy = cursor.fetchone()
    pharmacy_lat = pharmacy[0]
    pharmacy_lon = pharmacy[1]
    
    cursor.execute(f"SELECT status FROM drivers WHERE username = '{driver_username}'")
    status = cursor.fetchone()[0]
    
    total_duration = 0 #initialize total duration
    total_distance = 0 #initialize total distance
    
    if status == 'pharmacy':
        # driver to pharmacy
        duration_distance = durationDistance(driver_origin[0], driver_origin[1], pharmacy_lat, pharmacy_lon)
        total_duration += duration_distance["duration"]
        total_distance += duration_distance["distance"]
        for index, customer in enumerate(deliveries):
            if index == 0:
                duration_distance = durationDistance(pharmacy_lat, pharmacy_lon, customer[2], customer[3])
            else:
                duration_distance = durationDistance(old_customer[2], old_customer[3], customer[2], customer[3])
            total_duration += duration_distance["duration"]
            total_distance += duration_distance["distance"]
            old_customer = customer
    elif status ==  'user':
        for index, customer in enumerate(deliveries):
            if index == 0:
                duration_distance = durationDistance(driver_origin[0], driver_origin[1], customer[2], customer[3])
            else:
                duration_distance = durationDistance(old_customer[2], old_customer[3], customer[2], customer[3])
            total_duration += duration_distance["duration"]
            total_distance += duration_distance["distance"]
            old_customer = customer
    
    values = []
    converted_time = convertTime(total_duration)
    converted_distance = convertDistance(total_distance)
    values.append(converted_time)
    values.append(converted_distance)
    return values
    
@csrf_exempt
def getLiveETA(request, username, driver_username):
    # just returns the ETA from the database to the front end
    values = getEta(username, driver_username)
    results = {
        "ETA": values[0],
        "distance": values[1]
    }
    return JsonResponse(results)


@csrf_exempt
def updateDriver(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    cursor = connection.cursor()
    cursor.execute(f"UPDATE drivers SET latitude = {json_data['latitude']}, longitude = {json_data['longitude']}, status = '{json_data['status']}' WHERE username = '{json_data['username']}'")
    return JsonResponse({})


@csrf_exempt
def confirmOrder(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    driver_username = json_data['username']
    cursor = connection.cursor()
    cursor.execute(f"DELETE FROM customers WHERE driver_username = '{driver_username}' and delivery_order = {1}")
    cursor.execute(f"UPDATE customers SET delivery_order = delivery_order - 1 WHERE driver_username = '{driver_username}'")
    return JsonResponse({})


@csrf_exempt
def adddriver(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    for driver in json_data['drivers']:
        cursor = connection.cursor()
        cursor.execute('INSERT INTO drivers (username, first_name, last_name,  latitude, longitude, car, rating, profile, status) VALUES '
                       '(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);', (driver['username'], driver['first_name'], driver['last_name'], driver['latitude'], driver['longitude'], driver['car'], driver['rating'], driver['profile'], driver['status']))
    return JsonResponse({})
