require 'java'
Dir['lib/*.jar'].each { |j| require j}
require 'date'

module AgMIP
  module Translators
    class OryzaCrop
      include_package "org.agmip.core.types"
      include org.agmip.core.types.CropFile
      attr_accessor :data
      attr_accessor :location
      @@default_value = -99

      def initialize
        data = Array.new
        location = nil
      end

      def clear
        data.clear
        location = nil
      end

      def readFile(file)
        puts "Reading file " + file + "[ORYZA]"
        puts "NOT YET IMPLEMENTED!!!"
      end

      def writeFile(file, data)
        file = data.get("cul_id")+".crp"
        puts "Writing file " + file + "[ORYZA]"
        fh = File.open(file, 'w')
		fh.print("***********************************************************************************\r\n")
		fh.print("* Crop data file for ORYZA2000 rice growth model\r\n")     
		fh.print("* File name   : "+data.get("cul_id")+".crp\r\n")
		fh.print("* Crop        : "+data.get("cr") + "cv." + data.get("cul_name")+"\r\n") 
		fh.print("* Experiment  : "+data.get("design") + "\r\n")
		fh.print("* Information : "+data.get("people") + "\r\n")
        fh.print("***********************************************************************************\r\n")
		fh.print("\r\n")
		fh.print("* 1. Phenological development parameters\r\n")
		fh.printf("TBD    = %1.1f", data.getOr("",8.) + "! Base temperature for development (oC)\r\n")
		fh.printf("TBLV   = %1.1f", data.getOr("",8.) + "! Base temperature for juvenile leaf area growth (oC)\r\n")
		fh.printf("TMD    = %2.1f", data.getOr("",42.) + "! Maximum temperature for development (oC)\r\n")
		fh.printf("TOD    = %2.1f", data.getOr("",30.) + "! Optimum temperature for development (oC)\r\n")
		fh.printf("DVRJ  = %.6f", data.getOr("",.000639) + "! Development rate in juvenile phase (oCd-1)\r\n")
		fh.printf("DVRI  = %.6f", data.getOr("",.000758) + "! Development rate in photoperiod-sensitive phase (oCd-1)\r\n")
		fh.printf("DVRP  = %.6f", data.getOr("",.000672) + "! Development rate in panicle development (oCd-1)\r\n")
		fh.printf("DVRR  = %.6f", data.getOr("",.001564) + "! Development rate in reproductive phase (oCd-1)\r\n")
		fh.printf("MOPP   = %2.2f", data.getOr("",11.50) + "! Maximum optimum photoperiod (h)\r\n")
		fh.printf("PPSE   = %1.1f", data.getOr("",0.0) + "! Photoperiod sensitivity (h-1)\r\n")
		fh.printf("SHCKD  = %1.1f", data.getOr("",0.4) + "! Relation between seedling age and delay in phenological\r\n") 
		fh.print("   			    ! development (oCd oCd-1)\r\n")
		fh.print("\r\n")
		fh.print("* 2. Leaf and stem growth parameters\r\n")
		fh.printf("RGRLMX = %1.4f", data.getOr("",0.0085)  + "! Maximum relative growth rate of leaf area (oCd-1)\r\n")
		fh.printf("RGRLMN = %1.4f", data.getOr("",0.0040)  + "! Minimum relative growth rate of leaf area (oCd-1)\r\n")
		fh.printf("SHCKL  = %1.2f", data.getOr("",0.25)    + "! Relation between seedling age and delay in leaf area\r\n")
		fh.print("				 ! development (oCd oCd-1)\r\n")
		
=begin

* Switch to use SLA as table (give values below) or as fixed function
SWISLA = 'FUNCTION' ! Give function parameters  ASLA, BSLA, CSLA, DSLA, SLAMAX
*SWISLA = 'TABLE'   ! Give SLA as a function of DVS in the table SLATB

* If SWISLA='FUNCTION', supply SLA function parameters: 
* SLA = ASLA + BSLA*EXP(CSLA*(DVS-DSLA)), and SLAMAX
* parameters are derived from cv 2You725 used at Tuanlin 2000-2002
ASLA = 0.0018 ! (-)
BSLA = 0.0025 ! (-)
CSLA = -3.0   ! (-)
DSLA = 0.21   ! (-)
SLAMAX = 0.0045 ! maximum value of SLA (ha/kg)

* If SWISLA='TABLE', supply table of specific leaf area (ha kg-1; Y value) 
* as a function of development stage (-; X value):
SLATB = 0.00, 0.0045,
        0.16, 0.0045,
        0.33, 0.0033,
        0.65, 0.0028,
        0.79, 0.0024,
        2.10, 0.0023,
        2.50, 0.0023

* Table of specific green stem area (ha kg-1; Y value) as a function of 
* development stage (-; X value):
* data derived from experiment at Munoz, Philippines in dry season of 2001 using IR72
SSGATB = 0.0, 0.0008,   
         0.9, 0.0002,
         2.1, 0.0001,
         2.5, 0.0001

* data from IR72 as derived by Wopereis et al in dry season of 1992
*SSGATB = 0.0, 0.0003,   
*         0.9, 0.0003,
*         2.1, 0.0000,
*         2.5, 0.0000

* 3. Photosynthesis parameters
FRPAR  = 0.5  ! fraction of sunlight energy that is 
              ! photosynthetically active (-)
SCP    = 0.2  ! Scattering coefficient of leaves for PAR (-)
CO2REF = 340. ! Reference level of atmospheric CO2 (ppm)
CO2    = 340. ! Ambient CO2 concentration (ppm)

* Table of light extinction coefficient for leaves (-; Y-value) as a function
* of development stage (-; X value):
KDFTB = 0.00, 0.4,
        0.65, 0.4,
        1.00, 0.6,
        2.50, 0.6

* Table of extinction coefficient of N profile in the canopy (-; Y-value) 
* as a functionof development stage (-; X value):
KNFTB = 0.0, 0.4,
        2.5, 0.4 

* Table of light use effiency (-; Y-value) as a function of 
* temperature (oC; X value):
EFFTB  =   0.,0.54,
          10.,0.54,
          40.,0.36

* Table of effect of temperature on AMAX (-; Y-value) as a function of 
* temperature (oC; X value):
REDFTT = -10., 0.,
          10., 0.,
          20., 1.,
          37., 1.,
          43., 0.

* Table of N fraction in leaves on leaf area basis (g N m-2 leaf; Y-value) 
* as a function of development stage (-; X value):
* data from IR72 as derived by Wopereis et al in dry season of 1992
*NFLVTB = 0.00, 0.54,
*         0.16, 0.54,
*         0.33, 1.53,
*         0.65, 1.22,
*         0.79, 1.56,
*         1.00, 1.29,
*         1.46, 1.37,
*         2.02, 0.83,
*         2.50, 0.83
* parameters are derived from cv 2You725 used at Tuanlin 2000-2002
NFLVTB = 0.00, 2.00,
         0.30, 2.00,
         0.65, 1.80,
         1.00, 1.40,
         2.10, 0.90

* 4. Maintenance parameters
* Maintenance respiration coefficient (kg CH2O kg-1 DM d-1) of:
MAINLV = 0.02   ! Leaves 
MAINST = 0.015  ! Stems 
MAINSO = 0.003  ! Storage organs (panicles) 
MAINRT = 0.01   ! Roots 

TREF   = 25.    ! Reference temperature (oC)
Q10    = 2.     ! Factor accounting for increase in maintenance
                ! respiration with a 10 oC rise in temperature (-)

* 5. Growth respiration parameters 
* Carbohydrate requirement for dry matter production (kg CH2O kg-1 DM leaf) of:
CRGLV  = 1.326  ! Leaves 
CRGST  = 1.326  ! Stems
CRGSO  = 1.462  ! Storage organs (panicles)
CRGRT  = 1.326  ! Roots
CRGSTR = 1.11   ! Stem reserves

LRSTR  = 0.947  ! Fraction of allocated stem reserves that is
                ! available for growth (-)

* 6. Growth parameters
* parameter are derived from cv 2You725 used at Tuanlin 2000-2002
FSTR   = 0.20      ! Fraction of carbohydrates allocated to stems that
                   ! is stored as reserves (-)
TCLSTR = 10.       ! Time coefficient for loss of stem reserves (1 d-1)
SPGF   = 64900.    ! Spikelet growth factor (no kg-1)
WGRMX  = 0.0000249 ! Maximum individual grain weight (kg grain-1)

* Partitioning tables
* Table of fraction total dry matter partitioned to the shoot (-; Y-value) 
* as a function of development stage (-; X value):
FSHTB  = 0.00,  0.50,
         0.43,  0.75,
         1.00,  1.00,
         2.50,  1.00

* Table of fraction shoot dry matter partitioned to the leaves (-; Y-value) 
* as a function of development stage (-; X value):
* data from Wopereis et al dry season 1992 using IR72 at IRRI
*FLVTB  = 0.000, 0.60,
*         0.500, 0.60,
*         0.750, 0.30,
*         1.000, 0.00,
*         1.200, 0.00,
*         2.5  , 0. 

* parameters are derived from cv 2You725 used at Tuanlin 2000-2002
FLVTB = 0.000, 0.50,
        0.500, 0.50,
        0.750, 0.30,
        1.000, 0.00,
        1.200, 0.00,
        2.500, 0.00

* Table of fraction shoot dry matter partitioned to the stems (-; Y-value) 
* as a function of development stage (-; X value):
* data from Wopereis et al dry season 1992 using IR72 at IRRI
*FSTTB  = 0.000, 0.40,
*         0.500, 0.40,
*         0.750, 0.70,
*         1.000, 0.40,
*         1.200, 0.00,
*         2.5  , 0. 

* parameters are derived from cv 2You725 used at Tuanlin 2000-2002
FSTTB = 0.000, 0.50,
        0.500, 0.50,
        0.750, 0.70,
        1.000, 0.286,
        1.100, 0.00,
        1.200, 0.00,
        2.500, 0.00
* Table of fraction shoot dry matter partitioned to the panicles (-; Y-value) 
* as a function of development stage (-; X value):
* data from Wopereis et al dry season 1992 using IR72 at IRRI
*FSOTB  = 0.000, 0.000,
*         0.500, 0.000, 
*         0.750, 0.000,
*         1.000, 0.600,
*         1.200, 1.000,
*         2.5  , 1. 

* parameters are derived from cv 2You725 used at Tuanlin 2000-2002
FSOTB  = 0.000, 0.000,
         0.600, 0.000, 
         0.750, 0.000,
         1.100, 1.000,
         1.200, 1.000,
         2.5  , 1. 

* Table of leaf death coefficient (d-1; Y-value) as a function of development 
* stage (-; X value):
DRLVT  = 0.00, 0.000, 
         0.60, 0.000,
         1.00, 0.015,
         1.60, 0.025,
         2.10, 0.050,
         2.50, 0.050

* 7. Carbon balance parameters
* Mass fraction carbon (kg C kg-1 DM) in the:
FCLV   = 0.419  ! Leaves 
FCST   = 0.431  ! Stems
FCSO   = 0.487  ! Storage organs (panicles)
FCRT   = 0.431  ! Roots 
FCSTR  = 0.444  ! Stem reserves 

* 8. Root parameters
GZRT   = 0.01   ! Growth rate of roots (m d-1)
ZRTMCW = 0.25   ! Maximum depth of roots if no drought stress (m)
ZRTMCD = 0.40   ! Maximum depth of roots if drought (m)

* 9. Drought stress parameters
* Upper and lower limits for drought stress effects
ULLS =   74.13    ! Upper limit leaf rolling (kPa)
LLLS =  794.33    ! Lower limit leaf rolling (kPa)
ULDL =  630.95    ! Upper limit death of leaves (kPa)
LLDL = 1584.89    ! Lower limit death of leaves (kPa)
ULLE =    1.45    ! Upper limit leaf expansion (kPa) 
LLLE = 1404.      ! Lower limit leaf expansion (kPa)
ULRT =   74.13    ! Upper limit relative transpiration reduction (kPa)
LLRT = 1584.89    ! Lower limit relative transpiration reduction (kPa)
* Switch to use ULTR and LLTR as given above or function built in ORYZA 
* for the reduction in relative transpiration:
*SWIRTR = 'DATA'    ! Use data 
SWIRTR = 'FUNCTION' ! Use function 

*===================================================================*
* Drought stress effect parameters for aerobic rice                 *
* Values are for wheat, taken from SUCROS2 model                    *
*===================================================================*
* characteristic potential transpiration rate at a soil water
* content halfway wilting point and field capacity (mm.d-1)
  TRANSC = 6.

* Root activity coefficient (-)
  EDPTFT = 0.,0.15, 0.15,0.6, 0.3,0.8, 0.5,1., 1.1,1.
*===================================================================*

* 10. Nitrogen parameters
NMAXUP  = 8.      ! Maximum daily N uptake (kg N ha-1 d-1)
RFNLV   = 0.004   ! Residual N fraction of leaves (kg N kg-1 leaves)
FNTRT   = 0.15    ! Fraction N translocation from roots, as (additonal) 
                  ! fraction of total N translocation from stems and leaves (-)
RFNST   = 0.0015  ! Residual N fraction of stems (kg N kg-1 stems)
TCNTRF  = 10.     ! Time coefficient for N translocation to grains (d)
NFLVI   = 0.5     ! Initial leaf N fraction (on area basis: g N m-2 leaf)
FNLVI   = 0.025   ! Initial leaf N fraction (on weight basis: kg N kg-1 leaf)
NMAXSO  = 0.0175  ! Maximum N concentration in storage organs (kg N kg-1)

* Table of minimum N concentration in storage organs (kg N kg-1 DM; Y value) 
* as a function of the amount of N in the crop till flowering (kg N ha-1; X value):
NMINSOT =  0., .006,
          50., .0008,
         150., .0125,
         250., .015,
         400., .017,
        1000., .017

* Table of maximum leaf N fraction on weight basis (kg N kg-1 leaves; Y value)
* as a function of development stage (-; X value):
NMAXLT = 0.0,  .053,
         0.4,  .053,
         0.75, .040,
         1.0,  .028,
         2.0,  .022,
         2.5,  .015

*NMAXLT = 0.00, 0.057,
*         0.25, 0.057,
*         0.65, 0.032,
*         2.00, 0.015,
*         2.10, 0.014

* Table of minimum leaf N fraction on weight basis (kg N kg-1 leaves; Y value)
* as a function of development stage (-; X value):
NMINLT = 0.0, 0.025,
         1.0, 0.012,
         2.1, 0.007,
         2.5, 0.007

*NMINLT = 0.0, 0.025,
*         1.0, 0.010,
*         2.1, 0.005,
*         2.5, 0.005

*--- Table of effect of N stress on leaf death rate (-; Y value)
* as a function of N stress level (-; X value):
NSLLVT = 0.,  1.0,
         1.1, 1.0,
         1.5, 1.4,
         2.0, 1.5,
         2.5, 1.5
=end

		fh.printf("%.2d", data.get("wsta_long"))
        fh.printf("%.2d", data.get("wsta_lat"))
        fh.printf("%.2d", data.getOr("elev", @@default_value))
        fh.printf("%.2d", data.getOr("amth", 0.00))
        fh.printf("%.2d", data.getOr("angb", 0.00))

		weather = data.getOr("WeatherDaily", Array())
			weather.each { |d|
			date = data.getOr("w_date", Date.new)
			fh.printf("\r\n%2d  %4d  %2d  %5d %2.1d %2.1d %1.2d %1.1d %2.1d",
                    d.get("oryza_station_id"),
                    date.year,
                    date.strftime("%j"),
					d.getOr("srad", @@default_value),
					d.getOr("tmin", @@default_value),
					d.getOr("tmax", @@default_value),
					d.getOr("vprs", @@default_value),
					d.getOr("wind", @@default_value),
					d.getOr("rain", @@default_value))
        }
        fh.close
      end
    end
  end
end