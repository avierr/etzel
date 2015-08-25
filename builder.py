import shutil
import os, sys
import struct
size = struct.calcsize("P") * 8



try:
    Major=int(raw_input("Enter Major Version Number: "))
except ValueError:
    Major=0
    
try:
    Minor=int(raw_input("Enter Minor Version Number: "))
except ValueError:
    Minor=2
   

Machine=raw_input("Enter OS: ")

if Machine == "l":
    Machine="Linux"

elif Machine == "m":
    Machine="Mac" 

elif Machine == "w":
    Machine="Windows"

else:
    raise Exception('Incorrect OS Choice')       

os.path.exists("_rel/etzel_release/ldt") and shutil.rmtree("_rel/etzel_release/ldt")
os.mkdir("_rel/etzel_release/ldt", 0777)
os.chmod("_rel/etzel_release/ldt", 0777)

os.path.exists("_rel/etzel_release/log") and shutil.rmtree("_rel/etzel_release/log")
os.mkdir("_rel/etzel_release/log", 0777)
os.chmod("_rel/etzel_release/log", 0777)

Machine="-"+Machine+"-"+str(size)+"bit-"
op="etzel_release"+Machine+"v"+str(Major)+"."+str(Minor)+".zip"
os.system("cd _rel && zip -r "+op+" etzel_release")


