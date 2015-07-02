import userHandler
import GetRawSocialData
import GetConnFinalUser
import GetFinalSocialData
import GetConnGraphByFinalUser
import GetFinalRatingData
import GetMultiLevelUser
import dataSplitHandler
import GetTrustList_direct
import datetime

starttime = datetime.datetime.now()

# print '------------------userHandler------------------------'
# userHandler.main()

# print '------------------GetRawSocialData------------------------'
# GetRawSocialData.main()

# print '------------------GetConnFinalUser------------------------'
# GetConnFinalUser.main()

# print '------------------GetFinalSocialData------------------------'
# GetFinalSocialData.main()

# print '------------------GetConnGraphByFinalUser------------------------'
# GetConnGraphByFinalUser.main()

# print '------------------GetFinalRatingData------------------------'
# GetFinalRatingData.main()

# print '------------------GetMultiLevelUser------------------------'
# GetMultiLevelUser.main()

# print '------------------dataSplitHandler------------------------'
# for version in range(1,31):
	# print 'version %d' % version
	# version = str(version)
	# dataSplitHandler.main(version)

print '------------------GetTrustList_direct------------------------'	
for version in range(21,31):
	print 'version %d' % version
	version = str(version)
	GetTrustList_direct.main(version)	

	
print 'finished'
endtime = datetime.datetime.now()   
print 'passed time is %d s' % (endtime - starttime).seconds 