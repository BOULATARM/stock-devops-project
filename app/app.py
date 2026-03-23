from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

# Configuration de la base de données en fonction de l'environnement
if os.environ.get('FLASK_ENV') == 'testing':
    # En environnement de test, utiliser une base en mémoire
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///:memory:"
else:
    # En production, utiliser le volume persistant
    os.makedirs("/data", exist_ok=True)
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:////data/stock.db"

app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

class Product(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)

# Créer les tables (uniquement si ce n'est pas l'environnement de test)
if os.environ.get('FLASK_ENV') != 'testing':
    with app.app_context():
        os.makedirs("/data", exist_ok=True)
        db.create_all()

@app.route("/")
def index():
    products = Product.query.all()
    return render_template("index.html", products=products)

@app.route("/add", methods=["POST"])
def add_product():
    name = request.form.get("name")
    quantity = request.form.get("quantity")

    if name and quantity:
        product = Product(name=name, quantity=int(quantity))
        db.session.add(product)
        db.session.commit()

    return redirect(url_for("index"))

@app.route("/delete/<int:id>")
def delete_product(id):
    product = Product.query.get_or_404(id)
    db.session.delete(product)
    db.session.commit()
    return redirect(url_for("index"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)