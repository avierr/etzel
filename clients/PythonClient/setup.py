try:
	from setuptools import setup
except ImportError:
	from distutils.core import setup

config = {
	'description' : 'Python Client for Etzel',
	'author' : 'Kenric "AzureByte" D\'Souza',
	'url' : 'URL to get the project.',
	'download_url' : 'https://github.com/AzureByte/etzel',
	'author_email' : 'kenric.dsouza@gmail.com',
	'version' : '0.1',
	'install_requires' : ['nose'],
	'packages' : ['PythonClient'],
	'scripts' : [],
	'name' : 'PythonClient'
}

setup(**config)
