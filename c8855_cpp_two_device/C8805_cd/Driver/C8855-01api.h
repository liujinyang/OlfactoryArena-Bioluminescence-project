//LOG////////
//2019Sep.
//Libusb-1.0 version

//2020Mar.
//Add SetupEx() 


#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

#if defined(_MSC_VER)
	//  Microsoft
#if defined(C8855API_EXPORTS)
#define C8855API __declspec(dllexport)
#else
#define C8855API __declspec(dllimport)
#endif
#elif defined(__GNUC__)
	//  GCC
#define EXTERN_C //add by karp
#ifdef C8855API_EXPORTS
#define C8855API __attribute__ ((visibility("default")))
#else
#define C8855API
#endif

#define TRUE 1
#define FALSE 0

	typedef unsigned char BYTE;
	typedef unsigned char UCHAR;
	typedef short SHORT;
	typedef unsigned short WORD;
	typedef unsigned long DWORD;
	typedef unsigned long ULONG;
	typedef void* HANDLE;
	typedef int BOOL;
	typedef int INT;

	HANDLE INVALID_HANDLE_VALUE = (HANDLE)-1;
#else
	//  do nothing and hope for the best?
#define C8855API
#pragma warning Unknown dynamic link export/import semantics.
#endif

// Functions
	HANDLE C8855API C8855Open(void);
	BOOL C8855API C8855MOpen(BYTE board,
		HANDLE *handle1, HANDLE *handle2,
		HANDLE *handle3, HANDLE *handle4,
		HANDLE *handle5, HANDLE *handle6,
		HANDLE *handle7, HANDLE *handle8,
		HANDLE *handle9, HANDLE *handle10,
		HANDLE *handle11, HANDLE *handle12,
		HANDLE *handle13, HANDLE *handle14,
		HANDLE *handle15, HANDLE *handle16
	);
	BOOL C8855API C8855Close(HANDLE handle);
	BOOL C8855API C8855Reset(HANDLE handle);
	BOOL C8855API C8855CountStart(HANDLE handle, BYTE TriggerMode);
	BOOL C8855API C8855CountStop(HANDLE handle);
	BOOL C8855API C8855Setup(HANDLE handle, BYTE GateTime, BYTE TransferMode, WORD NumberOfGate);
	BOOL C8855API C8855ReadData(HANDLE handle, DWORD *DataBuffer, BYTE *ResultReturned);
	BOOL C8855API C8855SetPmtPower(HANDLE  handle, BYTE PowerStatus);
	BOOL C8855API C8855WritePort(HANDLE handle, BYTE Data);
	BOOL C8855API C8855ReadId(HANDLE handle, BYTE *Data);
	//Add@2020Mar.
	BOOL C8855API C8855SetupEx(HANDLE handle, BYTE GateTime, BYTE TransferMode, WORD NumberOfGate, BYTE TriggerEdge);

#define	C8855_GATETIME_50US         0x02
#define	C8855_GATETIME_100US        0x03
#define	C8855_GATETIME_200US        0x04
#define	C8855_GATETIME_500US        0x05
#define	C8855_GATETIME_1MS          0x06
#define	C8855_GATETIME_2MS          0x07
#define	C8855_GATETIME_5MS          0x08
#define	C8855_GATETIME_10MS         0x09
#define	C8855_GATETIME_20MS         0x0a
#define	C8855_GATETIME_50MS         0x0b
#define	C8855_GATETIME_100MS        0x0c
#define	C8855_GATETIME_200MS        0x0d
#define	C8855_GATETIME_500MS        0x0e
#define	C8855_GATETIME_1S           0x0f
#define	C8855_GATETIME_2S           0x10
#define	C8855_GATETIME_5S           0x11
#define	C8855_GATETIME_10S          0x12

#define C8855_SOFTWARE_TRIGGER      0
#define C8855_EXTERNAL_TRIGGER      1

#define	C8855_SINGLE_TRANSFER       1
#define	C8855_BLOCK_TRANSFER        2

#define C8855_PMT_POWER_OFF         0
#define C8855_PMT_POWER_ON          1
#define C8855_PMT_POWER_CHECK       2

#define C8855_ERROR_TRANSFER        0xFF

//Add@2020Mar.
#define C8855_SET_RISE_EDGE				1
#define C8855_SET_FALL_EDGE				0

#ifdef __cplusplus
}
#endif //__cplusplus



