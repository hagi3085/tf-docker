#pragma once
#include <chrono>
#include <fstream>
#include <string>

#ifndef __CSV_KILL

#define __TIME_REC_INIT__()				\
std::chrono::system_clock::time_point	start, end;	\
std::string  front;\
double elapsed 

#define __TIME_REC_INIT_LOGFILE__(str)				\
std::chrono::system_clock::time_point	start, end;	\
std::string  front;\
double elapsed; \
std::ofstream log(str,std::ios::app);\

#define __TIME_REC_INIT_LOGFILE_HEADER__(str,header)				\
__TIME_REC_INIT_LOGFILE__(str);\
log << header <<std::endl; 

#define __TIME_REC_START__()			\
start = std::chrono::system_clock::now()

#define __CONVERT_TIME_SCALE__(time) time/1000.0
#define __TIME_SCALE__ std::chrono::nanoseconds
#define __TIME_SCALE_NAME__   "us"
#define __TIME_SCALE_FORMAT__ "%8.2lf us \n"


#define __TIME_CALC__() \
end = std::chrono::system_clock::now();									\
elapsed = std::chrono::duration_cast<__TIME_SCALE__>(end-start).count();\

#define __TIME_REC_END__(str)			\
end = std::chrono::system_clock::now(); \
front = std::string(str); front += __TIME_SCALE_FORMAT__; \
elapsed = std::chrono::duration_cast<__TIME_SCALE__>(end-start).count(); \
printf( front.c_str(), __CONVERT_TIME_SCALE__(elapsed) )

#define __TIME_REC_END_CSV__(str)										\
__TIME_CALC__()	\
log <<  str <<","<< __CONVERT_TIME_SCALE__(elapsed) <<","<< __TIME_SCALE_NAME__

#define __TIME_REC_END_CSV_END_RECORD__(str)										\
__TIME_REC_END_CSV__(str)	<< std::endl

#define __TIME_REC_END_CSV_ADD_COLUMM__(str)										\
__TIME_REC_END_CSV__(str)	<< ","


#define __TIME_RECORD_STDCOUT(function,tag) \
__TIME_REC_START__();	\
function	;\
__TIME_REC_END__(tag)


#define __TIME_RECORD_CSV_COLUMM(function,tag) \
__TIME_REC_START__();	\
function	;\
__TIME_REC_END_CSV_ADD_COLUMM__(tag)

#define __TIME_RECORD_CSV_END(function,tag) \
__TIME_REC_START__();	\
function	;\
__TIME_REC_END_CSV_END_RECORD__(tag)
#else

#define __TIME_REC_INIT__()	

#define __TIME_REC_INIT_LOGFILE__(str)

#define __TIME_REC_INIT_LOGFILE_HEADER__(str,header)			

#define __TIME_REC_START__()	

#define __CONVERT_TIME_SCALE__(time)
#define __TIME_SCALE__ 
#define __TIME_SCALE_NAME__   
#define __TIME_SCALE_FORMAT__ 


#define __TIME_CALC__()

#define __TIME_REC_END__(str)

#define __TIME_REC_END_CSV__(str)

#define __TIME_REC_END_CSV_END_RECORD__(str)


#define __TIME_REC_END_CSV_ADD_COLUMM__(str)

#define __TIME_RECORD_STDCOUT(function,tag)\
function ;

#define __TIME_RECORD_CSV_COLUMM(function,tag) \
function ;

#define __TIME_RECORD_CSV_END(function,tag) \
function ;


#endif