from flask import Flask

application = Flask(__name__)

@application.route("/")
def home():
    return """
    <h1>Elastic Beanstalk Lab</h1>
    <p>Application deployed successfully!</p>
    """

if __name__ == "__main__":
    application.run(host="0.0.0.0", port=5000)