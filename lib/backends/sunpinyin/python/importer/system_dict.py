#!/usr/bin/python
from importer import load_system_dict

for word in load_system_dict():
    print word.encode('utf8')