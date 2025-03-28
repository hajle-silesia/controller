import unittest


class Test(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()

    def setUp(self):
        super().setUp()

    def test_placeholder(self):
        pass


if __name__ == "__main__":
    unittest.main()
