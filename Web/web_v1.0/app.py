from flask import Flask, request, render_template, jsonify,redirect, url_for, session, flash
from pymongo import MongoClient
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
import random
import datetime
import threading
import time
import googlemaps
# from datetime import datetime

#final Code


api_key='AIzaSyDbwtf_dATwlZNIgG6UqcVrPwsFheNK0os'

app = Flask(__name__)
app.secret_key = os.urandom(24)

client = MongoClient('mongodb+srv://Saood:Ambulance123@ambulance0.oajhybc.mongodb.net/?retryWrites=true&w=majority')
db = client['SIH']

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/intermediate')
def intermediate():
    return render_template('intermediate.html')

@app.route('/contactus')
def contactus():
    return render_template('contactus.html')

@app.route('/aboutus')
def aboutus():
    return render_template('aboutus.html')

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/loginpage')
def loginpage():
    return render_template('loginpage.html')

def generate_ambulanceUID():
    while True:
        random_number = ''.join(str(random.randint(0, 9)) for _ in range(5))
        if random_number != '00000' and not db.ambulance_reg.find_one({'uid': random_number}):
            return 'a' + random_number

def generate_hospitalUID():
    while True:
        random_number = ''.join(str(random.randint(0, 9)) for _ in range(5))
        if random_number != '00000' and not db.hospital_reg.find_one({'uid': random_number}):
            return 'h' + random_number

@app.route('/user_reg', methods=["GET", "POST"])
def user_reg():
    if request.method == 'POST':
        name = request.form["name"]
        address = request.form["address"]
        userAge = request.form["userAge"]
        phone = request.form["phone"]
        userEmail = request.form["userEmail"]
        username = request.form["username"]
        password = request.form["password"]

        existing_user = db.user_reg.find_one({'username': username})

        if existing_user:
            flash('Username already exists, please choose another username.')
        else:
            db.user_reg.insert_one({
                'name': name,
                'address': address,
                'age': userAge,
                'phone': phone,
                'email': userEmail,
                'username': username,
                'password': password
            })

            return "Account created successfully! You can now go to index page <a href='/user_login'>User Login</a>."
    return render_template("user_reg.html")

@app.route('/ambulance_reg', methods=["GET", "POST"])
def ambulance_reg():
    if request.method == 'POST':
        driverName = request.form['driverName']
        carNumber = request.form['carNumber']
        driverAge = request.form['driverAge']
        panNumber = request.form['panNumber']
        license = request.form['license']
        username = request.form['username']
        password = request.form['password']
        latitude=request.form['Latitude']
        longitude=request.form['longitude']

        uid = generate_ambulanceUID()
        existing_user = db.ambulance_reg.find_one({'username': username})
        print(latitude)
        print(longitude)
        if existing_user:
            flash('Username already exists, please choose another username.')
        else:
            db.ambulance_reg.insert_one({
                'driverName': driverName,
                'carNumber': carNumber,
                'driverAge': driverAge,
                'panNumber': panNumber,
                'license': license,
                'username': username,
                'password': password,
                'uid': uid,
                'latitude':latitude,
                'longitude':longitude,
            })

            return "Account created successfully! You can now go to ambulance page <a href='/ambulance_login'>Ambulance Login</a>."

    return render_template('ambulance_reg.html')

@app.route('/hospital_reg', methods=["GET", "POST"])
def hospital_reg():
    if request.method == 'POST':
        inchargeName = request.form['inchargeName']
        hospitalLocation = request.form['hospitalLocation']
        hospitalName = request.form['hospitalName']
        username = request.form['username']
        password = request.form['password']

        uid = generate_hospitalUID()
        existing_user = db.ambulance_reg.find_one({'username': username})

        if existing_user:
            flash('Username already exists, please choose another username.')
        else:
            db.hospital_reg.insert_one({
                'inchargeName': inchargeName,
                'hospitalLocation': hospitalLocation,
                'hospitalName': hospitalName,
                'username': username,
                'password': password,
                'uid': uid
            })

            return "Account created successfully! You can now go to hospital page <a href='/hospital_login'>Hospital login</a>."

    return render_template('hospital_reg.html')

@app.route("/user_login", methods=["GET", "POST"])
def user_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        user = db.user_reg.find_one({'username': username, 'password': password})

        if user:
            session['user_id'] = user['username']
            flash("Login Successful", "success")
            return redirect(url_for('user_booking', username = username, password = password))
        else: 
            flash("Invalid username or password. Please try again.", "error")

    return render_template("user_login.html")

@app.route("/ambulance_login", methods=["GET", "POST"])
def ambulance_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        user = db.ambulance_reg.find_one({'username': username, 'password': password})

        if user:
            session['user_id'] = user['username']
            flash("Login Successful", "success")
            return redirect(url_for('ambulance_notification', username = username, password = password))
        else:  
            flash("Invalid username or password. Please try again.", "error")

    return render_template("ambulance_login.html")

@app.route("/hospital_login", methods=["GET", "POST"])
def hospital_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        user = db.hospital_reg.find_one({'username': username, 'password': password})

        if user:
            session['user_id'] = user['username']
            flash("Login Successful", "success")
            return redirect(url_for('hospital_notification', username = username, password = password))
        else: 
            flash("Invalid username or password. Please try again.", "error")

    return render_template("hospital_login.html")

@app.route('/user_booking/<string:username>/<string:password>', methods=["GET", "POST"])
def user_booking(username, password):
    user_data = db.user_reg.find_one({'username': username, 'password': password})

    hospital_names = []
    for hosp_name in db.hospital_data.find():
        hospital_names.append(hosp_name["Hospital Name"])
    hospital_names.sort()
    
    # print(user_data)  # Check if user_data is retrieved correctly
    if request.method == 'POST':
        selected_hospitals = request.form.get('selected_hospitals')
        selected_hospitals = selected_hospitals.split(',') if selected_hospitals else []
        temp_id = []
        print(selected_hospitals)
        try:
            for h_name in selected_hospitals:
                print(h_name)
                results = db.hospital_reg.find({'hospitalName': h_name})
                for result in results:
                    print(result)  # This will print each document that matches the hospitalName
                    temp_id.append(result['uid'])
        except Exception as e:
            flash(f'Error fetching hospital details: {str(e)}', 'error')



        if temp_id:
            ref_id = temp_id
        else:
            ref_id = ["00000"]

        name = user_data['name']
        username = user_data['username']
        reason = request.form['reason']
        phone = user_data['phone']
        address = user_data['address']
        email = user_data['email']
        latitude = request.form['latitude']
        longitude = request.form['longitude']
        location = request.form['location']
        date = request.form['date']
        time = request.form['time']
        booking_type = request.form['bookingType']

        db.ambulance_pending.insert_one({
            'name': name,
            'user_username': username,
            'reason': reason,
            'phone': phone,
            'address': address,
            'email': email,
            'pickup_location': location,
            'latitude': latitude,
            'longitude': longitude,
            'date': date,
            'time': time,
            'booking_type': booking_type
        })
        db.hospital_pending.insert_one({
            'name': name,
            'user_username': username,
            'reason': reason,
            'phone': phone,
            'address': address,
            'email': email,
            'pickup_location': location,
            'latitude': latitude,
            'longitude': longitude,
            'date': date,
            'time': time,
            'booking_type': booking_type,
            'ref_id': ref_id
        })

        # flash('Booking successful', 'success')
        return redirect(url_for('getwellsoon', username=username, password=password))

    return render_template('user_booking.html', username=username, password=password, hospital_names=hospital_names)

@app.route('/get_list', methods=['GET'])
def get_list():
    # my_list = ["apple", "banana", "orange", "grape"]
    devices = []
    result = db.ambulance_reg.find()
    big_list = []
    for document in result:
          list = []
          list.append(document['username'])
          list.append(document['latitude'])
          list.append(document['longitude'])
          big_list.append(list)

     # Assign the big_list variable to the devices variable
    devices = big_list
    return jsonify(result=devices)

@app.route("/hospital_data_show",methods=["GET","POST"])
def hospital_data_show():
    hospital_names = db.hospital_data.distinct("Hospital Name")
    medical_categories = db.hospital_data.distinct("Medical Category")
    if request.method=="POST":
        hospital = request.form.get("hospital")
        medical_need = request.form.get("medicalNeed")
        print(hospital)
        print(medical_need)
        # Query MongoDB to get bed availability
        bed_data = db.hospital_data.find_one({"Hospital Name": hospital })
        available_beds = bed_data[medical_need]
        print(bed_data)
        print(available_beds)

        return render_template("hospital_data_show.html", hospital_names=hospital_names, medical_categories=medical_categories, available_beds=available_beds, bed_data=bed_data)

    return render_template("hospital_data_show.html", hospital_names=hospital_names, medical_categories=medical_categories)

@app.route('/ambulance_notification/<string:username>/<string:password>', methods=["GET", "POST"])
def ambulance_notification(username, password):
    ambu_data = db.ambulance_reg.find_one({'username': username, 'password': password})
    pending_data = db.ambulance_pending.find()
    accepted_data = db.ambulance_accepted.find({'ref_id': ambu_data['uid']})

    return render_template('ambulance_notification.html', username=username, password=password, pending_data=pending_data, accepted_data=accepted_data)

@app.route('/ambulance_notification/ambulance_delete/<string:user_username>')
def ambulance_delete(user_username):
    db.ambulance_accepted.delete_one({'user_username': user_username})
    return redirect(url_for('ambulance_notification'))

@app.route('/ambulance_notification/ambulance_accept/<string:user_username>/<string:username>/<string:password>')
def ambulance_accept(user_username, username, password):
    data = db.ambulance_pending.find_one({'user_username': user_username})

    ref_data = db.ambulance_reg.find_one({'username': username})
    db.ambulance_accepted.insert_one({
        'name': data['name'],
        'user_username': data['user_username'],
        'reason': data['reason'],
        'phone': data['phone'],
        'address': data['address'],
        'email': data['email'],
        'pickup_location': data['pickup_location'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'date': data['date'],
        'time': data['time'],
        'booking_type': data['booking_type'],
        'ref_id': ref_data['uid']
    })

    db.ambulance_pending.delete_one({'user_username': user_username})

    return redirect(url_for('ambulance_notification', username=username, password=password))

@app.route('/ambulance_notification/ambulance_end/<string:username>/<string:password>/<string:user_username>')
def ambulance_end(username, password, user_username):
    # db.ambulance_accepted.delete_one({'user_username': user_username})
    return redirect(url_for('payment_portal', username=username, password=password, user_username=user_username))

# @app.route('/live_location') 
# def live_location():
#     return render_template('live_location.html')

@app.route('/update_location/<string:username>/<string:password>', methods=['POST'])
def update_location(username,password):
    global updating_location
    while True:
        latitude = request.form.get('latitude')
        longitude = request.form.get('longitude')

        # Check if the username and password match a record in the database
        # ambulance_records = location_data.find_one({'username': username, 'password': password})
# 
        # if ambulance_records:
            # Update the location data for the matching user
        db.ambulance_reg.update_one(
            {'username': username, 'password': password},
            {'$set': {'latitude': latitude, 'longitude': longitude, 'timestamp': datetime.datetime.now()}}
        )
        if username and password:
            print(f"Location updated for user: {username}, Latitude {latitude}, Longitude {longitude} and the {datetime.datetime.now()}")
        else:
            print("Invalid username or password")

        time.sleep(10)

@app.route('/hospital_notification/<string:username>/<string:password>', methods=["GET", "POST"])
def hospital_notification(username, password):
    hosp_data = db.hospital_reg.find_one({'username': username, 'password': password})
    pending_data=None
    accepted_data=None
    if hosp_data is not None:
        pending_data = db.hospital_pending.find({'ref_id': {'$elemMatch': {'$in': [hosp_data['uid'], '00000']}}})
        accepted_data = db.hospital_accepted.find({'ref_id': hosp_data['uid']})
    else:
        # Handle the case where the hosp_data object is None
        pass

    return render_template('hospital_notification.html',username=username, password=password, pending_data=pending_data, accepted_data=accepted_data)

@app.route('/hospital_notification/hospital_delete/<string:user_username>')
def hospital_delete(user_username):
    db.hospital_accepted.delete_one({'user_username': user_username})
    return redirect(url_for('hospital_notification'))

@app.route('/hospital_notification/hospital_accept//<string:user_username>/<string:username>/<string:password>')
def hospital_accept(user_username, username, password):
    data = db.hospital_pending.find_one({'user_username': user_username})

    ref_data = db.hospital_reg.find_one({'username': username})
    db.hospital_accepted.insert_one({
        'name': data['name'],
        'user_username': data['user_username'],
        'reason': data['reason'],
        'phone': data['phone'],
        'address': data['address'],
        'email': data['email'],
        'pickup_location': data['pickup_location'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'date': data['date'],
        'time': data['time'],
        'booking_type': data['booking_type'],
        'ref_id': ref_data['uid']
    })

    db.hospital_pending.delete_one({'user_username': user_username})

    return redirect(url_for('hospital_notification', username=username, password=password))

@app.route('/hospital_notification/hospital_recieved//<string:user_username>/<string:username>/<string:password>')
def hospital_recieved(user_username, username, password):
    data = db.hospital_accepted.find_one({'user_username': user_username})
    db.recieved_patients.insert_one(data)
    db.hospital_accepted.delete_one({'user_username': user_username})
    return redirect(url_for('hospital_notification',username=username,password=password))

@app.route('/hospital_bed_management/<string:username>/<string:password>', methods=["GET", "POST"])
def hospital_bed_management(username, password):
    hosp_name = db.hospital_reg.find_one({'username': username, 'password': password})
    hosp_data = db.hospital_data.find_one({'Hospital Name': hosp_name['hospitalName']})
    if request.method == 'POST':
        ORTHO = int(request.form['ORTHO'])
        GYNE = int(request.form['GYNE'])
        CARDIO = int(request.form['CARDIO'])
        PULMO = int(request.form['PULMO'])
        OPTHALMO = int(request.form['OPTHALMO'])
        SURGERY = int(request.form['SURGERY'])
        MEDICINE = int(request.form['MEDICINE'])
        EMERGENCY = int(request.form['EMERGENCY'])

        # Connect to the database

        db.hospital_data.update_one(
            {'Hospital Name': hosp_name['hospitalName']},
            {'$set': {
                'ORTHO': ORTHO,
                'GYNE': GYNE,
                'CARDIO': CARDIO,
                'PULMO': PULMO,
                'OPTHALMO': OPTHALMO,
                'SURGERY': SURGERY,
                'MEDICINE': MEDICINE,
                'EMERGENCY': EMERGENCY
            }}
        )

        return redirect(url_for('hospital_bed_management', username=username, password=password))
    return render_template('hospital_bed_management.html', username=username, password=password, hosp_data=hosp_data)


@app.route('/ambulance_email/<string:username>/<string:password>/<string:user_username>', methods=["GET", "POST"])
def ambulance_email(username, password, user_username):
    gmaps=googlemaps.Client(key=api_key)

    result_ambulance=db.ambulance_reg.find_one({'username':username})
    ambulance_lat=0.0
    ambulance_lon=0.0
    if result_ambulance:
        ambulance_lat=result_ambulance['latitude']
        ambulance_lon=result_ambulance['longitude']
    # print("hello")
    # print(ambulance_lat)
    # print(ambulance_lon)
    uid=result_ambulance['uid']
    print(uid)
    result_user=db.ambulance_accepted.find_one({"ref_id":uid})
    user_lat=0.0
    user_lon=0.0
    if result_user:
        user_lat=result_user['latitude']
        user_lon=result_user['longitude']
    # print(user_lat)
    # print(user_lon)
    origin=(user_lat,user_lon)
    destination=(ambulance_lat,ambulance_lon)

    directions_result=gmaps.directions(
        origin,
        destination,
        mode='driving',
        # departure_time=datetime.now(),
    )

    distance = directions_result[0]['legs'][0]['distance']['text']
    duration = directions_result[0]['legs'][0]['duration']['text']

    print(distance)
    print(duration)
    

    gmail_user = 'healthlinkarchitects@gmail.com'
    gmail_password = 'hzex zsht hnkk ephu'
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(gmail_user, gmail_password)

    # name = request.args.get('name')
    user = db.ambulance_accepted.find_one({'user_username': user_username})
    print(user)
    if user:
        to_email = user['email']
        print(to_email)

        subject = 'Ambulance Confirmed'
        body = f'Ambulance has confirmed your ride. Your ambulance is on its way and it is {distance} away from you.It will arrive in just {duration}. Please hang tight.'
        msg = MIMEMultipart()
        msg['From'] = gmail_user
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))

        text = msg.as_string()
        server.sendmail(gmail_user, to_email, text)

        server.quit()

        flash("Email sent successfully")
    else:
        flash("User not found")

    return redirect(url_for('ambulance_notification', username=username, password=password))


# @app.route('/ambulance1_email/<string:name>', methods=["GET", "POST"])
# def ambulance1_email(name):
#     gmail_user = 'healthlinkarchitects@gmail.com'
#    gmail_password = 'iffr grps juil aelz'
#     server = smtplib.SMTP('smtp.gmail.com', 587)
#     server.starttls()
#     server.login(gmail_user, gmail_password)

#     # name = request.args.get('name')
#     user = db.ambulance1_accepted.find_one({'name': name})
#     if user:
#         to_email = user['email']
#         print(to_email)

#         subject = 'Ambulance Confirmed'
#         body = 'Ambulance has confirmed your ride. Your ambulance is on its way to you. Please hang tight.'
#         msg = MIMEMultipart()
#         msg['From'] = gmail_user
#         msg['To'] = to_email
#         msg['Subject'] = subject
#         msg.attach(MIMEText(body, 'plain'))

#         text = msg.as_string()
#         server.sendmail(gmail_user, to_email, text)

#         server.quit()

#         return "Email sent successfully"
#     else:
#         return "User not found"

# @app.route('/ambulance2_email')
# def ambulance2_email():
#     gmail_user = 'healthlinkarchitects@gmail.com'
#    gmail_password = 'iffr grps juil aelz'
#     server = smtplib.SMTP('smtp.gmail.com', 587)
#     server.starttls()
#     server.login(gmail_user, gmail_password)

#     name = request.args.get('name')
#     user = db.ambulance2_accepted.find_one({'name': name})
#     if user:
#         to_email = user['email']

#         subject = 'Ambulance Confirmed'
#         body = 'Ambulance has confirmed your ride. Your ambulance is on its way to you. Please hang tight.'
#         msg = MIMEMultipart()
#         msg['From'] = gmail_user
#         msg['To'] = to_email
#         msg['Subject'] = subject
#         msg.attach(MIMEText(body, 'plain'))

#         text = msg.as_string()
#         server.sendmail(gmail_user, to_email, text)

#         server.quit()

#         return "Email sent successfully"
#     else:
#         return "User not found"

@app.route('/hospital_email/<string:username>/<string:password>/<string:user_username>', methods=["GET", "POST"])
def hospital_email(username, password, user_username):
    gmail_user = 'healthlinkarchitects@gmail.com'
    gmail_password = 'hzex zsht hnkk ephu'
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(gmail_user, gmail_password)

    # user_username = request.args.get('user_username')
    user = db.hospital_accepted.find_one({'user_username': user_username})
    hosp = db.hospital_reg.find_one({'uid': user['ref_id']})
    if user:
        to_email = user['email']

        subject = 'Hospital Confirmed'
        body = hosp['hospitalName'] + ' has confirmed your booking. We will be waiting for your arrival.'
        msg = MIMEMultipart()
        msg['From'] = gmail_user
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body, 'plain'))

        text = msg.as_string()
        server.sendmail(gmail_user, to_email, text)

        server.quit()

        flash("Email sent successfully")
    else:
        flash("User not found")

    return redirect(url_for('hospital_notification', username=username, password=password))

# @app.route('/hospital1_email')
# def hospital1_email():
#     gmail_user = 'healthlinkarchitects@gmail.com'
#    gmail_password = 'iffr grps juil aelz'
#     server = smtplib.SMTP('smtp.gmail.com', 587)
#     server.starttls()
#     server.login(gmail_user, gmail_password)

#     name = request.args.get('name')
#     user = db.hospital1_accepted.find_one({'name': name})
#     if user:
#         to_email = user['email']

#         subject = 'Hospital Confirmed'
#         body = 'Amri Dhakuria has confirmed your booking. We will be waiting for your arrival.'
#         msg = MIMEMultipart()
#         msg['From'] = gmail_user
#         msg['To'] = to_email
#         msg['Subject'] = subject
#         msg.attach(MIMEText(body, 'plain'))

#         text = msg.as_string()
#         server.sendmail(gmail_user, to_email, text)

#         server.quit()

#         return "Email sent successfully"
#     else:
#         return "User not found"

# @app.route('/hospital2_email')
# def hospital2_email():
#     gmail_user = 'healthlinkarchitects@gmail.com'
#    gmail_password = 'iffr grps juil aelz'
#     server = smtplib.SMTP('smtp.gmail.com', 587)
#     server.starttls()
#     server.login(gmail_user, gmail_password)

#     name = request.args.get('name')
#     user = db.hospital2_accepted.find_one({'name': name})
#     if user:
#         to_email = user['email']

#         subject = 'Hospital Confirmed'
#         body = 'IRIS Health Services Limited has confirmed your booking. We will be waiting for your arrival.'
#         msg = MIMEMultipart()
#         msg['From'] = gmail_user
#         msg['To'] = to_email
#         msg['Subject'] = subject
#         msg.attach(MIMEText(body, 'plain'))

#         text = msg.as_string()
#         server.sendmail(gmail_user, to_email, text)

#         server.quit()

#         return "Email sent successfully"
#     else:
#         return "User not found"

# @app.route('/hospital_booking', methods=["GET", "POST"])
# def hospital_booking():
#     if request.method == 'POST':
#         name = request.form['name']
#         reason = request.form['reason']
#         phone = request.form['phone']
#         address = request.form['address']

#         db.hospital_pending.insert_one({
#             'name': name,
#             'reason': reason,
#             'phone': phone,
#             'address': address
#         })

#         return redirect(url_for('payment_portal'))

#     return render_template('hospital_booking.html')

@app.route('/getwellsoon/<string:username>/<string:password>', methods=["GET", "POST"])
def getwellsoon(username,password):
    if request.method == "POST":
        username_form = request.form.get('username')  # Get username from the form
        password_form = request.form.get('password')
        action = request.form.get('action')  # Get the action value
        print(action)
        if action == 'cancel':
            collection_pairs = [(db.ambulance_pending, db.hospital_pending), (db.ambulance_pending, db.hospital_accepted),
                        (db.ambulance_accepted, db.hospital_pending), (db.ambulance_accepted, db.hospital_accepted)]
            for c1, c2 in collection_pairs:
                c1.delete_one({"user_username": username_form})
                c2.delete_one({"user_username": username_form})
            return redirect(url_for('user_booking', username = username, password = password))
        elif action == 'rebooking':
            print("hi")
            data = db.ambulance_accepted.find_one({"user_username": username_form})
            del data['ref_id']
            db.ambulance_pending.insert_one(data)
            db.ambulance_accepted.delete_one({"user_username": username_form})
            flash("Ambulance Rebooked Successfully")
            # Handle rebooking logic here
             # Placeholder, replace with actual logic

    return render_template('getwellsoon.html', username=username, password=password)

@app.route('/payment_portal/<string:username>/<string:password>/<string:user_username>', methods=["GET", "POST"])
def payment_portal(username, password, user_username):
    if request.method == "POST":
        hospitalName = request.form.get('hospitalName')
        print(hospitalName)
        result = db.hospital_data.find_one({"Hospital Name": hospitalName})
        print(result)
        destination = " "
        if result:
            destination = result['Address']
            print(destination)
        else:
            return 'Hospital not found'
        print(destination)
        return render_template('payment_portal.html', username=username, password=password, user_username=user_username, destination=destination)
    
    # Handle GET requests for the same route
    return render_template('payment_portal.html', username=username, password=password, user_username=user_username, destination=None)

@app.route('/calculate/<string:username>/<string:password>/<string:user_username>', methods=["POST"])
def calculate(username, password, user_username):
    if request.method == "POST":
        result = request.form.get("result")  # Get the result from the hidden input field
        cost=request.form.get("cost")
        username=request.form.get("username")
        password=request.form.get("password")
        user_username=request.form.get("user_username")
        payment_method = request.form.get("paymentMethod")
        print("hello")
        print(result)
        print(payment_method)

        user_data = db.ambulance_accepted.find_one({'user_username': user_username})
        if result and payment_method:
            data = {
                "name": user_data['name'],
                "user_username": user_data['user_username'],
                "reason": user_data['reason'],
                "phone": user_data['phone'],
                "address": user_data['address'],
                "email": user_data['email'],
                "pickup_location": user_data['pickup_location'],
                "latitude": user_data['latitude'],
                "longitude": user_data['longitude'],
                "date": user_data['date'],
                "time": user_data['time'],
                "booking_type": user_data['booking_type'],
                "ambulance_id": user_data['ref_id'],
                "result": result,  # Store the result in your database
                "cost":cost,
                "paymentMethod": payment_method,  # Store the payment method in your database
            }

            # Store data in MongoDB
            db.trip_history.insert_one(data)
            gmail_user = 'healthlinkarchitects@gmail.com'
            gmail_password = 'hzex zsht hnkk ephu'
            server = smtplib.SMTP('smtp.gmail.com', 587)
            server.starttls()
            server.login(gmail_user, gmail_password)

                # user_username = request.args.get('user_username')
                # hosp = db.hospital_reg.find_one({'uid': user['ref_id']})
            if user_data:
                to_email = user_data['email']

                subject = 'Payment Confirmation'
                body = "Payment Successful, Thank You. We hope you get well soon."
                msg = MIMEMultipart()
                msg['From'] = gmail_user
                msg['To'] = to_email
                msg['Subject'] = subject
                msg.attach(MIMEText(body, 'plain'))

                text = msg.as_string()
                server.sendmail(gmail_user, to_email, text)

                server.quit()

                flash("Email sent successfully")
            else:
                flash("User not found")
            db.ambulance_accepted.delete_one({'user_username': user_username})


            return redirect(url_for("ambulance_notification", username = username, password = password))

    # Handle GET requests for the /calculate route
    return render_template("payment_portal.html", username=username, password=password, user_username=user_username)
    
@app.route('/getuserLoc/<string:user_username>')
def getuserLoc(user_username):
    result = db.ambulance_accepted.find_one({"user_username": user_username})
    if result:
        latitude = result['latitude']
        longitude = result['longitude']
        return render_template('getuserLoc.html', lati=latitude, longi=longitude)
    else:
        return "Location not available"

# @app.route('/getuserLoc1/<string:name>')
# def getuserLoc1(name):
#     result = db.ambulance1_accepted.find_one({"name": name})
#     if result:
#         latitude = result['latitude']
#         longitude = result['longitude']
#         return render_template('getuserLoc1.html', lati=latitude, longi=longitude)
#     else:
#         return "Location not available"

# @app.route('/getuserLoc2/<string:name>')
# def getuserLoc2(name):
#     result = db.ambulance2_accepted.find_one({"name": name})
#     if result:
#         latitude = result['latitude']
#         longitude = result['longitude']
#         return render_template('getuserLoc2.html', lati=latitude, longi=longitude)
#     else:
#         return "Location not available"

@app.route('/gethospitalLoc/<string:user_username>')
def gethospitalLoc(user_username):
    temp = db.hospital_accepted.find_one({"user_username": user_username})
    data = db.hospital_reg.find_one({'uid': temp['ref_id']})
    result = db.hospital_data.find_one({"Hospital Name": data["hospitalName"]})
    if result:
        address = result['Address']
        return render_template('gethospitalLoc.html', address=address)
    else:
        return "Location not available"

# @app.route('/gethospitalLoc1')
# def gethospitalLoc1():
#     result = db.hospital_list.find_one({"Hospital Name": "AMRI -Dhakuria"})
#     if result:
#         address = result['Address']
#         return render_template('gethospitalLoc1.html', address=address)
#     else:
#         return "Location not available"

# @app.route('/gethospitalLoc2')
# def gethospitalLoc2():
#     result = db.hospital_list.find_one({"Hospital Name": "IRIS Health Services Limited"})
#     if result:
#         address = result['Address']
#         return render_template('gethospitalLoc2.html', address=address)
#     else:
#         return "Location not available"

@app.route('/user_map/<string:username>')
def user_map(username):
    print(username)

        # Check if the form data is being received correctly
    print("Received username:", username)
        # print("Received password:", password)

        # Attempt to find a document in the MongoDB collection
    result = db.ambulance_accepted.find_one({"user_username": username})
    print(result)
    ans=0
    if result is not None:
        ans = result['ref_id']
        print("Found result:", ans)
    else:
        print("No matching document found.")
    user_latitude=result['latitude']
    user_longitude=result['longitude']
    print(user_latitude)
    print(user_longitude)
    ambulance_result=db.ambulance_reg.find_one({"uid":ans})
    ambulance_latitude=0.0
    ambulance_longitude=0.0
    if ambulance_result:
        ambulance_latitude=ambulance_result['latitude']
        ambulance_longitude=ambulance_result['longitude']
    print(ambulance_latitude)
    print(ambulance_longitude)
        
    return render_template('user_map.html',user_latitude=user_latitude,user_longitude=user_longitude,ambulance_latitude=ambulance_latitude,ambulance_longitude=ambulance_longitude,username=username)

if __name__ == '__main__':
    location_thread = threading.Thread(target=update_location)
    location_thread.daemon = True
    location_thread.start()

    app.run(debug=True)
