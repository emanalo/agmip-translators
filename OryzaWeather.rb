require 'java'
Dir['lib/*.jar'].each { |j| require j}
require 'date'

module AgMIP
  module Translators
    class OryzaWeather
      include_package "org.agmip.core.types"
      include org.agmip.core.types.weather.WeatherFile
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
        file = data.get("fl_loc_1")+data.get("oryza_station_id")+"."+date.year[1,3]
        puts "Writing file " + file + "[ORYZA]"
        fh = File.open(file, 'w')
        fh.print("*******************************************************\r\n")       
		fh.print("* File name    : "+data.get("fl_loc_1")+data.get("oryza_station_id")+"."+(data.get("year")[1,3])+"\r\n")
		fh.print("* Station name : "+data.get("wsta_name") + "\r\n")
		fh.print("*              : "+data.get("wsta_site") + "\r\n") 
		fh.print("* Year         : "+data.get("wsta_name") + "\r\n")
		fh.print("* Longitude    : "+data.get("wsta_long"))
		fh.print("* Latitude     : "+data.get("wsta_lat"))
		fh.print("* Elevation    : "+data.get("flele") + "\r\n")
		fh.print("* Author       : "+data.get("people") + "\r\n")
		fh.print("*                "+data.get("data_source") + "\r\n")
		fh.print("* Comments     : "+data.get("design") + "\r\n")  
        fh.print("* Col Description\r\n")
        fh.print("* 1  station code\r\n")
        fh.print("* 2  year\r\n")
        fh.print("* 3  julian day\r\n")
        fh.print("* 4  solar radiation (KJ m-2)\r\n")
        fh.print("* 5  minimum temperature (degrees Celsius)\r\n")
        fh.print("* 6  maximum temperature (degrees Celsius)\r\n")
        fh.print("* 7  vapor pressure at 0800H (KPa)\r\n")
        fh.print("* 8  wind speed (m s-1)\r\n")
        fh.print("* 9  precipitation and/or irrigation (mm)\r\n")
        fh.print("*******************************************************\r\n")
        fh.printf("%.2d", data.get("wsta_long"))
        fh.printf("%.2d", data.get("wsta_lat"))
        fh.printf("%.2d", data.getOr("elev", @@default_value))
        fh.printf("%.2d", data.getOr("anga", 0.00))
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