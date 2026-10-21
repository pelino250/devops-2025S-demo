# Create your tests here.
from django.test import TestCase


class SanityTest(TestCase):
    def test_sanity(self):
        self.assertEqual(1 + 1, 2)
