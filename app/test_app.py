import unittest
from app import app, db, Product

class FlaskTestCase(unittest.TestCase):

    def setUp(self):
        app.config['TESTING'] = True
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        self.client = app.test_client()

        with app.app_context():
            db.create_all()

    def tearDown(self):
        with app.app_context():
            db.drop_all()

    def test_home_page(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)

    def test_add_product(self):
        response = self.client.post('/add', data={
            'name': 'Test Product',
            'quantity': 10
        }, follow_redirects=True)

        self.assertEqual(response.status_code, 200)

    def test_delete_product(self):
        with app.app_context():
            product = Product(name='Test', quantity=5)
            db.session.add(product)
            db.session.commit()
            product_id = product.id

        response = self.client.get(f'/delete/{product_id}', follow_redirects=True)
        self.assertEqual(response.status_code, 200)

if __name__ == "__main__":
    unittest.main()