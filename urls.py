"""website URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from app import views

urlpatterns = [
    path('getdrivers/', views.getdrivers, name='getdrivers'),
    path('getclosestdriver/<str:username>/<str:lat>/<str:lon>/<str:username_lat>/<str:username_lon>', views.getclosestdriver, name='getclosestdriver'),
    path('getliveeta/<str:username>/<str:driver_username>', views.getLiveETA, name='getliveeta'),
    path('adddriver/', views.adddriver, name='adddriver'),
    path('updatedriver/', views.updateDriver, name='updateDriver'),
    path('confirmOrder/', views.confirmOrder, name='confirmOrder'),
    path('admin/', admin.site.urls)
]
