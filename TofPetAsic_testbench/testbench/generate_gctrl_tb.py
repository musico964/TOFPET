from random import uniform, choice
from math import log, exp
from sets import Set


def binary(value, n):
	s = ''
	for i in range(n):
		s = str(value & 0x1) + s
		value = value >> 1
	return s

def generatePoisson(rate, nChannels, fS, genTime):
	eventList = []
	lastEventTime = 0	
	while lastEventTime < genTime:
		nHits = choice([1,2]); actualRate = 2/3.0 * rate;
	#	nHits = 3; actualRate = rate/nHits
	
		dt = -log(uniform(0,1))/(actualRate*nChannels)
		eventTime = lastEventTime + dt	
		eventClock = long(eventTime * fS)
		tcoarse = eventClock & 0x3FF

		availableChannels = [ x for x in range(nChannels) ]

		for hit in range(nHits):
			ecoarse = tcoarse + int(uniform(0, 70))
			soc = int(uniform(0, 1024))
			teoc = int(soc + uniform(0, 350))
			eeoc = int(soc + uniform(0, 350))
			conversionTime = int(uniform(120, 460));
			channel = choice(availableChannels); availableChannels.remove(channel)
			tac = choice([0, 1, 2, 3])
			
			eventList.append((eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac))

		lastEventTime = eventTime

	return eventList

def generateCorner(rate, nChannels, fS, genTime):
	T = 1/fS
	tenFrames = 1024*10*T

	eventList = []
	
	baseTime = 0
	for nBurst in [1,2,3,4]:
		for i in range(nBurst):
			for channel in range(nChannels):
				eventTime = baseTime + tenFrames * nBurst + 3*i*T + 10*T
				eventClock = long(eventTime * fS)
				tcoarse = eventClock & 0x3FF
				ecoarse = tcoarse + int(uniform(0, 70))
				soc = int(uniform(0, 1024))
				teoc = int(soc + uniform(0, 350))
				eeoc = int(soc + uniform(0, 350))
				conversionTime = 120
				tac = eventClock % 4
				eventList.append((eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac))

	baseTime += 10*tenFrames
	for nBurst in [1,2,3,4]:
		for i in range(nBurst):
			for channel in range(nChannels):
				eventTime = baseTime + tenFrames * nBurst + 1024*T*i/4 + 10*T
				eventClock = long(eventTime * fS)
				tcoarse = eventClock & 0x3FF
				ecoarse = tcoarse + int(uniform(0, 70))
				soc = int(uniform(0, 1024))
				teoc = int(soc + uniform(0, 350))
				eeoc = int(soc + uniform(0, 350))
				conversionTime = 120
				tac = eventClock % 4
				eventList.append((eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac))

	baseTime += 10*tenFrames
	lastEventTime = 0
	for i in range(1024):
		dt = 0.5 / (nChannels * rate)
		eventTime = baseTime + lastEventTime + dt
		eventClock = long(eventTime * fS)
		tcoarse = eventClock & 0x3FF
		ecoarse = tcoarse + int(uniform(0, 70))
		soc = int(uniform(0, 1024))
		teoc = int(soc + uniform(0, 350))
		eeoc = int(soc + uniform(0, 350))
		channel = i % nChannels
		conversionTime = 120
		tac = eventClock % 4
		eventList.append((eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac))
		lastEventTime += dt

	baseTime += 10 * tenFrames
	eventList.append((long(baseTime * fS), 0, 0, 0, 0, 0, 0, 0))

	return eventList
		


fS = 160E6;
nChannels = 64
rate = 160E3
genTime =  0.1 # seconds
print "Generating events..."
eventList = generatePoisson(rate, nChannels, fS, genTime)


print "Processing events for stimulus"
for channelIter in range(nChannels):
	stimFile = open("gctrl_64mx_tb_data/stimulus_%d.dat" % channelIter, "w");
	lastInjectionClock = 0
	for eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac in eventList:
		if channel != channelIter:
			continue;

		if eventClock < lastInjectionClock:
			injectionClock = lastInjectionClock + conversionTime 
		else:
			injectionClock = eventClock + conversionTime

		lastInjectionClock = injectionClock

		tcoarse = eventClock & 0x3FF	
		frame = (eventClock >> 10) & 0x1
		stimFile.write(binary(injectionClock, 42))
		stimFile.write(binary(tac, 2))
		stimFile.write(binary(frame, 1))
		stimFile.write(binary(tcoarse, 10))
		stimFile.write(binary(ecoarse, 10))
		stimFile.write(binary(soc, 10))	
		stimFile.write(binary(teoc, 10))	
		stimFile.write(binary(eeoc, 10))	
		stimFile.write("\n")
		

	stimFile.close()

#for eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel in eventList:
#	tcoarse = eventClock & 0x3FF	
#	print "%d %d %d %d %d %d" % (channel, tcoarse, ecoarse, soc, teoc, eeoc), " *  %d %d %d %d" % (tcoarse, ecoarse - tcoarse, teoc - soc, eeoc - soc)


print "Processing events for verification"
frames = [ eventClock >> 10 for eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac in eventList ]
lastFrame = max(frames) + 2
verificationEvents = [ (eventClock >> 10, eventClock & 0x3FF, ecoarse, soc, teoc, eeoc, channel, tac) for eventClock, conversionTime, ecoarse, soc, teoc, eeoc, channel, tac in eventList ]

maxFrameEvents = 0
verFile = open("gctrl_64mx_tb_data/verification.dat", "w")
eventIter = 0
n = len(verificationEvents)
for frameIter in range(lastFrame+10):
	frameEvents = []
	while eventIter < n:
		frame, tcoarse, ecoarse, soc, teoc, eeoc, channel, tac = verificationEvents[eventIter]	
		if frame != frameIter:
			break
		else:
			frameEvents.append((tcoarse, ecoarse, soc, teoc, eeoc, channel, tac))
			eventIter += 1
						
	frameEvents = frameEvents[0:254] # Limit count to 255 in verification file anyway..
	maxFrameEvents = max([maxFrameEvents, len(frameEvents)]);

	verFile.write(binary(frameIter, 32))
	verFile.write("\n")
	verFile.write(binary(len(frameEvents), 16))
	verFile.write("\n")
#	print "Frame %d has %d events" % (frameIter, len(frameEvents))
	for tcoarse, ecoarse, soc, teoc, eeoc, channel, tac in frameEvents:
		verFile.write(binary(tac, 2))		
		verFile.write(binary(tcoarse, 10))
		verFile.write(binary(ecoarse - tcoarse, 10))
		verFile.write(binary(teoc - soc, 10))
		verFile.write(binary(eeoc - soc, 10))
		verFile.write(binary(channel, 7))
		verFile.write("\n")		

verFile.close()

print "%d events in %d frames = %f events/frame" % (n, frameIter+1, float(n)/(frameIter+1))
print "%d events in %f seconds = %f events/second/channel" % (n, genTime, n/genTime/nChannels)
print "Largest frame has %d events" % (maxFrameEvents,)
