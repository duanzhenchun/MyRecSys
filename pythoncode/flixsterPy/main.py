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

for version in range(21,31):
	print 'version is %d' % version
	version = str(version)
	print '------------------userHandler------------------------'
	userHandler.main(version)

	print '------------------GetRawSocialData------------------------'
	GetRawSocialData.main(version)

	print '------------------GetConnFinalUser------------------------'
	GetConnFinalUser.main(version)

	print '------------------GetFinalSocialData------------------------'
	GetFinalSocialData.main(version)

	print '------------------GetConnGraphByFinalUser------------------------'
	GetConnGraphByFinalUser.main(version)

	print '------------------GetFinalRatingData------------------------'
	GetFinalRatingData.main(version)

	print '------------------GetMultiLevelUser------------------------'
	GetMultiLevelUser.main(version)

	print '------------------dataSplitHandler------------------------'
	dataSplitHandler.main(version)

	print '------------------GetTrustList_direct------------------------'	
	GetTrustList_direct.main(version)	

	
print 'finished'
endtime = datetime.datetime.now()   
print 'passed time is %d s' % (endtime - starttime).seconds 