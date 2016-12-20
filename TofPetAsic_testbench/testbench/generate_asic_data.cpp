#include <math.h>
#include <stdio.h>
#include <vector>
#include <assert.h>
#include <boost/lexical_cast.hpp>
#include <boost/random.hpp>
#include <boost/nondet_random.hpp>

using namespace std;
using namespace boost;

static const int nChannels = 64;
static const float eventRate =160E3;
static const float darkRate = 1E6;
static const float tThreshold = 0.5;
static const float eThreshold = 10;

static const float tPeakT = 1E-9;
static const float alphaT = 1.0;
static const float tPeakE = 4.0;
static const float alphaE = 0.5;

static const double maxToT = 400E-9;
static const double maxD1 = 1.5E-9;
static const double maxD2 = 400E-9;

static const double Ts = 10E-12;



class Signal {
private:
	static const unsigned long blockSize = 2048;
public:
	Signal(unsigned long long nBins)
	{	
		this->nBins = nBins;
		this->nPages = nBins/blockSize + 1;
		this->data = new float *[nPages];
		for(unsigned long long i = 0; i < nPages; i++)
			data[i] = NULL;
		
	};
	
	~Signal()
	{
		for(unsigned long long i = 0; i < nPages; i++) {
			if (data[i] != NULL)
				delete [] data[i];
		}
		delete [] data;
	};
	
	float get(unsigned long long binIndex)
	{	
		unsigned long long pageIndex = binIndex / blockSize;
		unsigned long long slotIndex = binIndex % blockSize;
		
		if(pageIndex >= nPages) return 0;
		
		if(data[pageIndex] == NULL)
			return 0;
					
		float *page = data[pageIndex];
		return page[slotIndex];
	}
	
	void set(unsigned long long binIndex , float v) {
		unsigned long long pageIndex = binIndex / blockSize;
		unsigned long long slotIndex = binIndex % blockSize;
		
		if(pageIndex >= nPages) return;
		
		if(data[pageIndex] == NULL) {
			if(v == 0.0) return;
		
			float * page = data[pageIndex] = new float [blockSize];
			for(int i = 0; i < blockSize;  i++) {
				page[i] = 0.0;
			}			
		}
		
		float *page = data[pageIndex];
		page[slotIndex] = v;
	};
	
	unsigned long long search(unsigned long long binIndex, float v) {
		
		unsigned long long pageIndex = binIndex / blockSize;
		unsigned long long slotIndex = binIndex % blockSize;
		while(true) {
			if(pageIndex >= nPages)
				return (1ULL<<63) - 1;
				
			float *page = data[pageIndex];
			
			if(page == NULL) {
				pageIndex += 1;
				slotIndex = 0;
				continue;
			}
			
			for(int i =  slotIndex; i < blockSize; i++) {
				if(page[i] >= v) {
					unsigned long long r = (pageIndex * blockSize + i);
//					printf("Search from %lld returning %lld\n", binIndex, r);
					return r;
					
				}
			}
			
			pageIndex += 1;
			slotIndex = 0;
		}
		
	};
	
private:
	float **data;
	double binWidth;
	unsigned long long nBins;
	unsigned long long nPages;
	
};


static inline float PulseShapeF(float alpha, float beta, float t, float pedestal, float A, float tMax);
static void addPulse(Signal &signal, double t0, double A, double tPeak, double alpha);
static void addStep(Signal &signal, double t0, double A, double delay, double tot);



int main(int argc, char *argv[])
{
	assert(argc > 1);

	float runTime = boost::lexical_cast<float>(argv[1]);

	printf("Generating events for %lf seconds\n", runTime); 

	mt19937 generator;
	generator.seed(time_t(10));
	uniform_real<> range(0, 1);
    variate_generator<mt19937&, uniform_real<> > next(generator, range);

	
	for(int i = 0; i < nChannels; i++)
	{
		char fName[1024];
	
		printf("Channel = %2d\n", i);
		
		unsigned long long nBins = (long long)((runTime + 10E-6)/Ts);
		Signal pulseT(nBins);
		Signal pulseE(nBins);
		
		sprintf(fName, "asic_64_tb3_data/channel_%d_trues.txt", i);
		FILE * eventResume = fopen(fName, "w");
		double t = 0;
		unsigned nEvent = 0;
		while(true) {
			float u = next();
			float A = 2 * eThreshold + 10000 * next();
			float tot = maxToT * next();
			float d1 = 2 * maxD1 * (next() - 0.5);
			float d2 = 2 * maxToT * (next() - 0.5);
			
			t = t - log(u)/eventRate;
			if(t > runTime) break;
			
			nEvent += 1;
			
//			addPulse(pulseT, t, A, tPeakT, alphaT);
//			addPulse(pulseE, t, A, tPeakT, alphaT);

			addStep(pulseT, t, 10*eThreshold, d1 > 0 ? +d1 : 0, d2 > 0 ? tot + d2 : tot);
			addStep(pulseE, t, 10*eThreshold, d1 > 0 ? -d1 : 0, d2 < 0 ? tot - d2 : tot);
			
			fprintf(eventResume, "%1.12lf %f\n", t, A);
			
			if(nEvent % 128 == 0)
				printf("S1 %4.0f%%\r", float(100 * t/runTime)); fflush(stdout);			
		}
		fclose(eventResume);
		
		
		sprintf(fName, "asic_64_tb3_data/channel_%d_dark.txt", i);
		FILE * darkResume = fopen(fName, "w");
		
		t = 0;
		nEvent = 0;
		while(true) {
			float u = next();
			float A = 1;
			
			t = t - log(u)/darkRate;
			if(t > runTime) break;
			
			nEvent += 1;
			
			addPulse(pulseT, t, A, tPeakT, alphaT);
			addPulse(pulseE, t, A, tPeakT, alphaT);
			
			fprintf(darkResume, "%1.12lf %f\n", t, A);
			if(nEvent % 128 == 0)
				printf("S2 %4.0f%%\r", float(100 * t/runTime)); fflush(stdout);
		}
		fclose(darkResume);
		
		
		sprintf(fName, "asic_64_tb3_data/channel_%d_T.dat", i);
		FILE * tFile = fopen(fName, "w");
		sprintf(fName, "asic_64_tb3_data/channel_%d_E.dat", i);
		FILE * eFile = fopen(fName, "w");
		
	
		int iT = 0;	t = 0;
		bool DOT = false; unsigned long long DOTtoggleTime = 0;		
		bool DOE = false; unsigned long long DOEtoggleTime = 0;
		
		nEvent = 0;
		while (iT < nBins) {
			t = iT * Ts;
			unsigned long long tI = (unsigned long long) round(t * 1E12);
			
			bool nDOT = pulseT.get(iT) >= tThreshold;
			bool nDOE = pulseE.get(iT) >= eThreshold;
			
			if(DOT != nDOT) {
				fprintf(tFile, "%030llu\n", tI-DOTtoggleTime);
					DOTtoggleTime = tI;
			}
			
			if(DOE != nDOE) {						
				fprintf(eFile, "%030llu\n", tI-DOEtoggleTime);
					DOEtoggleTime = tI;
					
				if(DOE) 
					nEvent += 1;
				if(nEvent % 128 == 0)
					printf("S3 %4.0f%%\r", float(100 * t/runTime)); fflush(stdout);			
							
			}
			
			
		
			DOT = nDOT;
			DOE = nDOE;
			
			if(!nDOT && !nDOE) {
				unsigned long long iDOT = pulseT.search(iT+1, tThreshold);
				unsigned long long iDOE = pulseE.search(iT+1, eThreshold);
				unsigned long long niT = (iDOT < iDOE) ? iDOT : iDOE;
				iT = niT;
			}
			else {			
				iT += 1;
			}
		} 
		fclose(tFile);
		fclose(eFile);
		
			
	}

	return 0;
}

 
float PulseShape(float alpha, float beta, float t, float pedestal, float A, float tMax)
{
	float tPeak = alpha * beta;
	return 
		t <= (tMax - tPeak) ? 
		pedestal : 
		A * powf((t - (tMax - tPeak))/tPeak, alpha) * expf(-alpha * (t-tMax)/tPeak) + pedestal;
}

void addPulse(Signal &signal, double t0, double A, double tPeak, double alpha)
{
	unsigned long long bin0 = (unsigned long long)floor(t0 / Ts);	
	double t = 0;
	float v = 0;
	unsigned long long i = 0;
	do {
		t = i * Ts;		
		v = PulseShape(alpha, tPeak*1E9/alpha, t*1E9, 0, A, tPeak*1E9);		
		signal.set(bin0+i, signal.get(bin0+i) + v);		
		i++;
	} while((t < tPeak) || (v > 0.01));
	
}

static void addStep(Signal &signal, double t0, double A, double delay, double tot)
{
	unsigned long long bin0 = (unsigned long long)floor((t0+delay)/Ts);
	unsigned long long i = 0;
	double t = 0;
	
	do {
		t = i * Ts;
		signal.set(bin0+i, signal.get(bin0+i) + A);		
		i++;
	} while(t < tot);

}
