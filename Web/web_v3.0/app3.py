from flask import Flask, request, render_template, redirect, url_for, session
import mysql.connector, smtplib
import os
from flask import flash, session
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


app = Flask(__name__)
app.secret_key = os.urandom(24)



# Database configuration
db = mysql.connector.connect(
    host = "localhost",
    user =  "root",
    password =  "",
    database = "sih"
)

cursor = db.cursor()
# cursor = db.cursor(buffered=True)

#Landing Page
@app.route('/')
def index():
    return render_template('index.html')

# Intermediate Page
@app.route('/intermediate')
def intermediate():
    return render_template('intermediate.html')

# Contact Us Page
@app.route('/contactus')
def contactus():
    return render_template('contactus.html')

# About Us Page
@app.route('/aboutus')
def aboutus():
    return render_template('aboutus.html')

# Signup Page
@app.route('/signup')
def signup():
    return render_template('signup.html')

# Login Page
@app.route('/loginpage')
def loginpage():
    return render_template('loginpage.html')



# User Signup Page
@app.route('/user_reg', methods=["GET", "POST"])
def user_reg():
    if request.method == 'POST':
        # Handle the user registration form data here
        # You can access form data using request.form
        Name = request.form['Name']
        userLocation = request.form['userLocation']
        userAge = request.form['userAge']
        userEmail = request.form['userEmail']
        username = request.form['username']
        password = request.form['password']
        cursor = db.cursor()

        query = "INSERT INTO user_reg (name, location, age, email,  username, password) VALUES ( %s, %s, %s, %s, %s, %s)"
        values = (Name, userLocation, userAge, userEmail, username, password)

        cursor.execute(query, values)
        db.commit()

        return "Account created successfully! You can now go to index page <a href='/user_login'>User Login</a>."
        # Perform data storage or processing here (e.g., store in a database)
    return render_template("user_reg.html")


# Ambulance Signup Page
@app.route('/ambulance_reg', methods=["GET", "POST"])
def ambulance_reg():
    if request.method == 'POST':
        # Handle the ambulance driver registration form data here
        # You can access form data using request.form
        driverName = request.form['driverName']
        carNumber = request.form['carNumber']
        driverAge = request.form['driverAge']
        panNumber = request.form['panNumber']
        license = request.form['license']
        username = request.form['username']
        password = request.form['password']

        cursor = db.cursor()

        query = "INSERT INTO ambulance_reg (driverName, carNumber, driverAge, panNumber, license, username, password) VALUES (%s, %s, %s, %s, %s, %s,%s)"
        values = (driverName, carNumber, driverAge, panNumber, license, username, password) 

        cursor.execute(query, values)
        db.commit()

        return "Account created successfully! You can now go to ambulance page <a href='/ambulance_login'>Ambulance Login</a>."
        # Perform data storage or processing here (e.g., store in a database)
    return render_template('ambulance_reg.html')


# Hospital signup Page
@app.route('/hospital_reg', methods=["GET", "POST"])
def hospital_reg():
    if request.method == 'POST':
        # Handle the hospital registration form data here
        # You can access form data using request.form
        inchargeName = request.form['inchargeName']
        hospitalLocation = request.form['hospitalLocation']
        hospitalName = request.form['hospitalName']
        username = request.form['username']
        password = request.form['password']

        cursor = db.cursor()

        query = "INSERT INTO hospital_reg (inchargeName, hospitalLocation, hospitalName, username, password) VALUES (%s, %s, %s, %s, %s)"
        values = (inchargeName, hospitalLocation, hospitalName, username, password) 

        cursor.execute(query, values)
        db.commit()

        return "Account created successfully! You can now go to hospital page <a href='/hospital_login'>Hospital login</a>."
        # Perform data storage or processing here (e.g., store in a database)
    return render_template('hospital_reg.html')


# User Login Page
@app.route("/user_login", methods=["GET", "POST"])
def user_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        cursor = db.cursor()
        query = "SELECT username, name FROM user_reg WHERE username = %s AND password = %s"
        cursor.execute(query, (username, password))
        user = cursor.fetchone()

        if user:
            session['user_id'] = user[0]
            flash("Login Successful", "success")
            return redirect(url_for('user_booking'))  # Redirect to the intermediate page
        else: 
            flash("Invalid username or password. Please try again.", "error")

    return render_template("user_login.html")

# Ambulance Login Page
@app.route("/ambulance_login", methods=["GET", "POST"])
def ambulance_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        cursor = db.cursor()
        query = "SELECT username, driverName FROM ambulance_reg WHERE username = %s AND password = %s"
        cursor.execute(query, (username, password))
        user = cursor.fetchone()

        if user:
            session['user_id'] = user[0]
            flash("Login Successful", "success")
            cursor = db.cursor()
            query = "SELECT id FROM ambulance_reg WHERE username = %s"
            cursor.execute(query, (username,))
            id = str(cursor.fetchone()[0])
            if id == "1":
                return redirect(url_for('ambulance1_notification'))  # Redirect to the intermediate page
            elif id == "2":
                return redirect(url_for('ambulance2_notification'))  # Redirect to the intermediate page
        else:  
            flash("Invalid username or password. Please try again.", "error")

    return render_template("ambulance_login.html", )

# Hospital Login Page
@app.route("/hospital_login", methods=["GET", "POST"])
def hospital_login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        cursor = db.cursor()
        query = "SELECT username, inchargeName FROM hospital_reg WHERE username = %s AND password = %s"
        cursor.execute(query, (username, password))
        user = cursor.fetchone()

        if user:
            session['user_id'] = user[0]
            flash("Login Successful", "success")
            cursor = db.cursor()
            query = "SELECT sno FROM hospital_reg WHERE username = %s"
            cursor.execute(query, (username,))
            id = str(cursor.fetchone()[0])
            if id == "1":
                return redirect(url_for('hospital1_notification'))  # Redirect to the intermediate page
            elif id == "2":
                return redirect(url_for('hospital2_notification'))  # Redirect to the intermediate page
        else: 
            flash("Invalid username or password. Please try again.", "error")

    return render_template("hospital_login.html", )

# Ambulance_notification Page

@app.route('/ambulance1_notification', methods=["GET", "POST"])
def ambulance1_notification():
    cursor.execute("SELECT * FROM ambulance_booking")
    pending_data = cursor.fetchall()
    
    cursor.execute("SELECT * FROM ambulance1_accepted")
    accepted_data = cursor.fetchall()
    
    return render_template('ambulance1_notification.html', pending_data=pending_data, accepted_data=accepted_data)

@app.route('/ambulance1_notification/ambulance1_delete')
def ambulance1_delete():
    cursor.execute(f"DELETE FROM ambulance1_accepted WHERE sno = '1'")
    db.commit()
    return redirect(url_for('ambulance1_notification'))


@app.route('/ambulance1_notification/ambulance1_accept/<int:sno>')
def ambulance1_accept(sno):
    cursor.execute(f"SELECT * FROM ambulance_booking WHERE id = {sno}")
    data = cursor.fetchone()

    cursor.execute(f"INSERT INTO ambulance1_accepted (name, reason, phone, address, pickup_location, pickup_time, latitude, longitude, booking_type) VALUES ('{data[1]}', '{data[2]}', '{data[3]}', '{data[4]}', '{data[5]}', '{data[6]}', '{data[7]}', '{data[8]}', '{data[9]}')")
    db.commit()

    cursor.execute(f"DELETE FROM ambulance_booking WHERE id = {sno}")
    db.commit()

    return redirect(url_for('ambulance1_notification'))


@app.route('/ambulance2_notification', methods=["GET", "POST"])
def ambulance2_notification():
    cursor.execute("SELECT * FROM ambulance_booking")
    pending_data = cursor.fetchall()
    
    cursor.execute("SELECT * FROM ambulance2_accepted")
    accepted_data = cursor.fetchall()
    
    return render_template('ambulance2_notification.html', pending_data=pending_data, accepted_data=accepted_data)

@app.route('/ambulance2_notification/ambulance2_delete')
def ambulance2_delete():
    cursor.execute(f"DELETE FROM ambulance2_accepted WHERE sno = '1'")
    db.commit()
    return redirect(url_for('ambulance2_notification'))

@app.route('/ambulance2_notification/ambulance2_accept/<int:sno>')
def ambulance2_accept(sno):
    cursor.execute(f"SELECT * FROM ambulance_booking WHERE id = {sno}")
    data = cursor.fetchone()

    cursor.execute(f"INSERT INTO ambulance2_accepted (name, reason, phone, address, pickup_location, pickup_time, latitude, longitude, booking_type) VALUES ('{data[1]}', '{data[2]}', '{data[3]}', '{data[4]}', '{data[5]}', '{data[6]}', '{data[7]}', '{data[8]}', '{data[9]}')")
    db.commit()

    cursor.execute(f"DELETE FROM ambulance_booking WHERE id = {sno}")
    db.commit()

    return redirect(url_for('ambulance2_notification'))

@app.route('/ambulance1_notification/ambulance1_email')
def ambulance1_email():

    # Gmail account details
    gmail_user = 't1234estingdata@gmail.com'
    gmail_password = 'slvzkbumifinpuvu'

    # Establish a secure session with Gmail's outgoing SMTP server using your gmail account
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(gmail_user, gmail_password)

    cursor.execute("SELECT user_reg.email FROM user_reg JOIN ambulance1_accepted ON user_reg.name = ambulance1_accepted.name")
    to_email = cursor.fetchone()[0]

    # Recipient's email address
    # result = cursor.fetchone()[0]
    # if result is not None:
    #     to_email = result
    # else:
    #     print("Error")
    
    # Create the email content
    subject = 'Ambulance Confirmed'
    body = 'Ambulance has confirmed your ride. Your ambulance is on its way to you. Please hang tight.'
    msg = MIMEMultipart()
    msg['From'] = gmail_user
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send the email
    text = msg.as_string()
    server.sendmail(gmail_user, to_email, text)

    # Close the server connection
    server.quit()

    return "Email sent successfully"

@app.route('/ambulance2_notification/ambulance2_email')
def ambulance2_email():

    # Gmail account details
    gmail_user = 't1234estingdata@gmail.com'
    gmail_password = 'slvzkbumifinpuvu'

    # Establish a secure session with Gmail's outgoing SMTP server using your gmail account
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(gmail_user, gmail_password)

    cursor.execute("SELECT user_reg.email FROM user_reg JOIN ambulance2_accepted ON user_reg.name = ambulance2_accepted.name;")

    # Recipient's email address
    to_email = cursor.fetchone()[0]
    
    # Create the email content
    subject = 'Ambulance Confirmed'
    body = 'Ambulance has confirmed your ride. Your ambulance is on its way to you. Please hang tight.'
    msg = MIMEMultipart()
    msg['From'] = gmail_user
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send the email
    text = msg.as_string()
    server.sendmail(gmail_user, to_email, text)

    # Close the server connection
    server.quit()

    return "Email sent successfully"


# Hospital Notification Page

@app.route('/hospital1_notification', methods=["GET", "POST"])
def hospital1_notification():
    cursor.execute("SELECT * FROM hospital_pending")
    pending_data = cursor.fetchall()
    
    cursor.execute("SELECT * FROM hospital1_accepted")
    accepted_data = cursor.fetchall()
    
    return render_template('hospital1_notification.html', pending_data=pending_data, accepted_data=accepted_data)

@app.route('/hospital1_notification/hospital1_delete/<int:sno>/<string:table>')
def hospital1_delete(sno, table):
    cursor.execute(f"DELETE FROM {table} WHERE sno = {sno}")
    db.commit()
    return redirect(url_for('hospital1_notification'))

@app.route('/hospital1_notification/hospital1_accept/<int:sno>')
def hospital1_accept(sno):
    cursor.execute(f"SELECT * FROM hospital_pending WHERE sno = {sno}")
    data = cursor.fetchone()

    cursor.execute(f"INSERT INTO hospital1_accepted (name, reason, phone, address) VALUES ('{data[1]}', '{data[2]}', '{data[3]}', '{data[4]}')")
    db.commit()

    cursor.execute(f"DELETE FROM hospital_pending WHERE sno = {sno}")
    db.commit()

    return redirect(url_for('hospital1_notification'))

@app.route('/hospital1_notification/hospital1_received/<int:sno>')
def hospital1_received(sno):
    cursor.execute(f"DELETE FROM hospital1_accepted WHERE sno = {sno}")
    db.commit()
    return redirect(url_for('hospital1_notification'))


@app.route('/hospital2_notification', methods=["GET", "POST"])
def hospital2_notification():
    cursor.execute("SELECT * FROM hospital_pending")
    pending_data = cursor.fetchall()
    
    cursor.execute("SELECT * FROM hospital2_accepted")
    accepted_data = cursor.fetchall()
    
    return render_template('hospital2_notification.html', pending_data=pending_data, accepted_data=accepted_data)

@app.route('/hospital2_notification/hospital2_delete/<int:sno>/<string:table>')
def hospital2_delete(sno, table):
    cursor.execute(f"DELETE FROM {table} WHERE sno = {sno}")
    db.commit()
    return redirect(url_for('hospital2_notification'))

@app.route('/hospital2_notification/hospital2_accept/<int:sno>')
def hospital2_accept(sno):
    cursor.execute(f"SELECT * FROM hospital_pending WHERE sno = {sno}")
    data = cursor.fetchone()

    cursor.execute(f"INSERT INTO hospital2_accepted (name, reason, phone, address) VALUES ('{data[1]}', '{data[2]}', '{data[3]}', '{data[4]}')")
    db.commit()

    cursor.execute(f"DELETE FROM hospital_pending WHERE sno = {sno}")
    db.commit()

    return redirect(url_for('hospital2_notification'))

@app.route('/hospital2_notification/hospital2_received/<int:sno>')
def hospital2_received(sno):
    cursor.execute(f"DELETE FROM hospital2_accepted WHERE sno = {sno}")
    db.commit()
    return redirect(url_for('hospital2_notification'))

@app.route('/hospital1_notification/hospital1_email')
def hospital1_email():

    # Gmail account details
    gmail_user = 't1234estingdata@gmail.com'
    gmail_password = 'slvzkbumifinpuvu'

    # Establish a secure session with Gmail's outgoing SMTP server using your gmail account
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(gmail_user, gmail_password)

    cursor.execute("SELECT user_reg.email FROM user_reg JOIN hospital1_accepted ON user_reg.name = hospital1_accepted.name;")

    # Recipient's email address
    to_email = cursor.fetchone()[0]
    
    # Create the email content
    subject = 'Hospital Confirmed'
    body = 'Amri Dhakuria has confirmed your booking. We will be waiting for your arrival.'
    msg = MIMEMultipart()
    msg['From'] = gmail_user
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send the email
    text = msg.as_string()
    server.sendmail(gmail_user, to_email, text)

    # Close the server connection
    server.quit()

    return "Email sent successfully"

@app.route('/hospital2_notification/hospital2_email')
def hospital2_email():

    # Gmail account details
    gmail_user = 't1234estingdata@gmail.com'
    gmail_password = 'slvzkbumifinpuvu'

    # Establish a secure session with Gmail's outgoing SMTP server using your gmail account
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(gmail_user, gmail_password)

    cursor.execute("SELECT user_reg.email FROM user_reg JOIN hospital2_accepted ON user_reg.name = hospital2_accepted.name;")

    # Recipient's email address
    to_email = cursor.fetchone()[0]
    
    # Create the email content
    subject = 'Hospital Confirmed'
    body = 'Howrah District Hospital has confirmed your booking. We will be waiting for your arrival.'
    msg = MIMEMultipart()
    msg['From'] = gmail_user
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send the email
    text = msg.as_string()
    server.sendmail(gmail_user, to_email, text)

    # Close the server connection
    server.quit()

    return "Email sent successfully"

# User Booking Page
@app.route('/user_booking', methods=["GET", "POST"])
def user_booking():
    if request.method == 'POST':
        name = request.form['name']
        reason = request.form['reason']
        phone = request.form['phone']
        address = request.form['address']
        latitude = request.form['latitude']
        longitude = request.form['longitude']
        location = request.form['location']
        date = request.form['date']
        time = request.form['time']
        booking_type = request.form['bookingType']

        cursor = db.cursor()
        query = "INSERT INTO ambulance_booking (name, reason, contact_number, address, pickup_location, latitude, longitude, booking_type) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
        values = (name, reason, phone, address, location, latitude, longitude, booking_type)

        cursor.execute(query, values)
        db.commit()

        flash('Booking successful', 'success')
        return redirect(url_for('hospital_booking'))

    return render_template('user_booking.html')

@app.route('/hospital_booking', methods=["GET", "POST"])
def hospital_booking():
    if request.method == 'POST':
        # hospital = request.form['hospital']
        # location = request.form['location']
        name = request.form['name']
        reason = request.form['reason']
        phone = request.form['phone']
        address = request.form['address']


        cursor.execute("INSERT INTO hospital_pending (name, reason, phone, address) VALUES (%s, %s, %s, %s)",
                        (name, reason, phone, address))
        db.commit()
        return redirect(url_for('getwellsoon'))
        # # Check if the hospital and bed exist in the hospital_list table
        # cursor.execute("SELECT * FROM hospital_list WHERE name = %s AND location = %s", (hospital, location))
        # if cursor.fetchone():
        #     # If a match is found, insert the data into hospital_pending
        #     cursor.execute("INSERT INTO hospital_pending (name, reason, phone, address) VALUES (%s, %s, %s, %s)",
        #                 (name, reason, phone, address))
        #     db.commit()
        #     return redirect(url_for('getwellsoon'))
        # else:
        #     return 'ERROR'
    return render_template('hospital_booking.html')

@app.route('/getwellsoon')
def getwellsoon():
    return render_template('getwellsoon.html')

@app.route('/getuserLoc1')
def getuserLoc1():
    cursor.execute(f"SELECT latitude, longitude FROM ambulance1_accepted WHERE sno = 1")
    result = cursor.fetchone()
    if result is not None:
        latitude = result[0]
        longitude = result[1]
    print(latitude, longitude)
    return render_template('getuserLoc1.html', lati=latitude, longi=longitude)


@app.route('/getuserLoc2')
def getuserLoc2():
    cursor.execute(f"SELECT latitude, longitude FROM ambulance2_accepted WHERE sno = 1")
    result = cursor.fetchone()
    if result is not None:
        latitude = result[0]
        longitude = result[1]
    print(latitude, longitude)
    return render_template('getuserLoc2.html', lati=latitude, longi=longitude)

@app.route('/gethospitalLoc1')
def gethospitalLoc1():
    cursor.execute(f"SELECT latitude, longitude FROM hospital_list WHERE name = 'Amri' AND location = 'Dhakuria'")
    result = cursor.fetchone()
    if result is not None:
        latitude = result[0]
        longitude = result[1]
    print(latitude, longitude)
    return render_template('gethospitalLoc1.html', lati=latitude, longi=longitude)

@app.route('/gethospitalLoc2')
def gethospitalLoc2():
    cursor.execute(f"SELECT latitude, longitude FROM hospital_list WHERE name = 'Howrah District Hospital' AND location = 'Howrah'")
    result = cursor.fetchone()
    if result is not None:
        latitude = result[0]
        longitude = result[1]
    print(latitude, longitude)
    return render_template('gethospitalLoc2.html', lati=latitude, longi=longitude)


#Main
if __name__ == '__main__':
    app.run(debug=True)
