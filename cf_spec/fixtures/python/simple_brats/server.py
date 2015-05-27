import MySQLdb
import bcrypt
import psycopg2
import sys
import hiredis


from flask import Flask
app = Flask(__name__)

port = int(sys.argv[1])


@app.route("/")
def hello():
    return "Hello, World"


@app.route("/bcrypt")
def test_bcrypt():
    return bcrypt.hashpw("Hello, bcrypt".encode('utf-8'), bcrypt.gensalt())


@app.route("/mysql")
def test_mysql():
    MySQLdb.connect(passwd="moonpie", db="testing")


@app.route("/pg")
def test_pg():
    psycopg2.connect("dbname=test user=postgres")


@app.route("/redis")
def test_redis():
    reader = hiredis.Reader()
    reader.feed("$5\r\nHello\r\n") 
    return reader.gets()


app.debug = True

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=port)
