#geocoding addresses
# eventually to be mixed in with stata hopefully
# takes in list of address/names of places
# queries google maps and return the lat long and full address
# to an output csv
# run on a csv file name to_be_geo_code.csv (address-city-state format)

# import libraries that we need to do some geocoding
from bs4 import BeautifulSoup as bs
import numpy as np
import csv
import pandas
import time
import os
from urllib.request import Request
import urllib.request as ureq
import json


# settings.py file needed to run (contains path)
# can comment out below and set set path manually as needed
# settings.init()
# os.chdir(settings.path)

# name of file you want geocoded
# formatt - name - address - city - state
file = 'to_be_geo_coded.csv'
# ------------------------

# read in file from csv that contains the adddress city and state for each entry
# creates lists of each value to iterate through
def read_addresses():
    colnames = ['name','address','city','state','index'] # names for co
    data = pandas.read_csv(file, names=colnames)
    global name_list, city_list, state_list, address_list, index_list
    to_geo_code = pandas.DataFrame(data)
    name_list = to_geo_code["name"].tolist()
    city_list = to_geo_code["city"].tolist()
    state_list = to_geo_code["state"].tolist()
    address_list = to_geo_code["address"].tolist()
    index_list = to_geo_code["index"].tolist()

def collect_geocoding():
    # address_list = ["616 Hastings st.","500 Colleg Ave"]
    # city_list = ["Pittsburgh", "Swarthmore"]
    # state_list = ["PA", "PA"]
    results = []
    global geo_code_results
    labels = ['g_lat','g_lng','g_address','type_geocode','orig_name', 'orig_address','orig_city','orig_state', 'index']
    for i in range(len(address_list)):
        time.sleep(1)
        print(i)
        a_c_s = go_code(name_list[i], address_list[i], city_list[i], state_list[i]) #return list of [lat,lon,address]
        a_c_s.append(name_list[i])
        a_c_s.append(address_list[i])
        a_c_s.append(city_list[i])
        a_c_s.append(state_list[i])
        a_c_s.append(index_list[i])
        results.append((a_c_s))
        if i%50 == 0:
            geo_code_results= pandas.DataFrame.from_records(results, columns=labels)
            export_to_csv()
    geo_code_results= pandas.DataFrame.from_records(results, columns=labels)
    return geo_code_results

def go_code(name, address, city, state):

    name = str(name)
    city = str(city)
    address = str(address)
    state = str(state)

    name = name.replace(" ","+")
    city = city.replace(" ","+")
    state = state.replace(" ","+")
    address = address.replace(" ","+")

    name = name.replace("   ","+")
    city = city.replace("   ","+")
    state = state.replace(" ","+")
    address = address.replace(" ","+")

    name = name.replace("&","+")
    city = city.replace("&","+and+")
    state = state.replace("&","+and+")
    address = address.replace("&","+and+")

    q = name+","+address+","+city+","+state
    print(q)
    alt_key = "AIzaSyBm9CYyRp_uDfZpszXY8MZObUt_HbL7cZs"
    key = "AIzaSyCfVd8mWNCNVNmbJJBHns0FsQMkzQAmtCM"
    url_with_address = "https://maps.googleapis.com/maps/api/geocode/xml?address="+name+","+address+","+city+","+state+"&key="+key
    returned = Request(url_with_address).encode('utf8')#, headers={'User-Agent': 'Mozilla/5.0'})
    website = ureq.urlopen(returned).read()
    soup = bs(website, 'lxml')
    try:
        latitude = soup.find('location').find('lat').get_text()
        longitude = soup.find('location').find('lng').get_text()
        full_address = soup.find('formatted_address').get_text()
        type_geocode = soup.find('location_type').get_text()
        info_to_return = [latitude, longitude, full_address, type_geocode]
    except:
        info_to_return = ["error", "error", "error", "error"]
    return info_to_return
def export_to_csv():
    geo_code_results.to_csv('results_of_geo_code_with_names.csv')


if __name__ == '__main__':
    read_addresses()
    collect_geocoding()
    export_to_csv()
