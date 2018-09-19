file = open("DATA/palabras.txt", "r")
l = ""
for line in file:
    l += line[0:-1] 

print l