import sys


codePath=sys.path[0]
s=codePath.split('\\')
workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\movielens\\commondata\\'  #f:\project\somproject
f=file(workPath+'testSet5.txt','r')
ratingList=f.readlines()
f.close()

user_set = set()
item_set = set()
for line in ratingList:
	data = line[:-1].split('\t')
	uid = data[0]
	iid = data[1]
	user_set.add(uid)
	item_set.add(iid)

print len(user_set)
print len(item_set)