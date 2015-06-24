import MySQLdb
import bcrypt
import psycopg2
import sys
import hiredis


from scipy import special, optimize
from flask import Flask
app = Flask(__name__)

port = int(sys.argv[1])


@app.route("/")
def hello():
    return "Hello, World"


@app.route("/bcrypt")
def test_bcrypt():
    return bcrypt.hashpw("Hello, bcrypt".encode('utf-8'), bcrypt.gensalt(prefix=b"2a"))


@app.route("/mysql")
def test_mysql():
    try:
        MySQLdb.connect(passwd="moonpie", db="testing")
    except MySQLdb.OperationalError as e:
        return e.args[1]


@app.route("/pg")
def test_pg():
    try:
        psycopg2.connect("dbname=test user=postgres")
    except psycopg2.OperationalError as e:
        return e.args[0]


@app.route("/redis")
def test_redis():
    reader = hiredis.Reader()
    reader.feed("$5\r\nHello\r\n") 
    return reader.gets()


@app.route("/scipy")
def test_scipy():
    f = lambda x: -special.jv(3, x)
    optimize.minimize(f, 1.0)
    return "Hello Scipy"

app.debug = True

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=port)
