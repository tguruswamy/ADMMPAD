< envPaths
errlogInit(20000)

dbLoadDatabase("$(TOP)/dbd/mmpadDetectorApp.dbd")
mmpadDetectorApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "MMPAD3x2:")
# The port name for the detector
epicsEnvSet("PORT",   "MMPAD")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "487")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "195")
# The maximum number of time seried points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")


###
# Create the asyn port to talk to the Pilatus on port 41234.
drvAsynIPPortConfigure("camserver","164.54.106.89:41234")
#drvAsynIPPortConfigure("camserver","10.0.1.150:41234")
#drvAsynIPPortConfigure("camserver","gse-pilatus1:41234")

# Set the input and output terminators.
asynOctetSetInputEos("camserver", 0, "\x18")
asynOctetSetOutputEos("camserver", 0, "\n")

asynSetTraceIOMask("camserver",0,2)
asynSetTraceMask("camserver",0,9)

mmpadDetectorConfig("$(PORT)", "camserver", $(XSIZE), $(YSIZE), 50, 200000000)
dbLoadRecords("$(ADMMPAD)/db/mmpad.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,CAMSERVER_PORT=camserver")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, -1)
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int32,FTVL=LONG,NELEMENTS=94965")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd
set_requestfile_path("$(ADMMPAD)/mmpadApp/Db")

#asynSetTraceMask("$(PORT)",0,255)
#asynSetTraceMask("$(PORT)",0,3)


iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")
