require_relative 'stl/parser'

class STL
    # @!attribute faces
    #   @return [Array<Face>]  the list of faces
    attr_reader :faces

    # @!attribute max
    #   @return [Point]  the maximum extent of the solid
    attr_reader :max

    # @!attribute min
    #   @return [Point]  the minimum extent of the solid
    attr_reader :min

    # @!attribute name
    #   @return [String]  The name of the solid, or nil
    attr_accessor :name

    # Read an STL file
    # @param filename [String]	The path to the file to read
    # @return [STL] the resulting {STL} object
    def self.read(filename)
	File.open(filename, 'r') {|f| STL::Parser.parse(f) }
    end

    # Write to an STL file
    # @param filename	[String]    The path to write to
    # @param faces	[Face]	    An array of faces to write
    # @param format	[Symbol]    Pass :ascii to write an ASCII formatted file, and :binary to write a binary file
    def self.write(filename, faces, format=:binary)
	File.open(filename, 'w') do |file|
	    if format == :ascii
		file.puts "solid #{name}"
		faces.each do |face|
		    file.puts "    facet normal %E %E %E" % [*face.normal]
		    file.puts "\touter loop"
		    face.points.each do |point|
			file.puts "\t    vertex %E %E %E" % [*point]
		    end
		    file.puts "\tendloop"
		    file.puts '    endfacet'
		end
		file.puts 'endsolid '
	    elsif format == :binary
		file.write 'STL Ruby'.ljust(80, "\0")	# A meager header
		file.write [faces.length].pack('V')	# The triangle count

		faces.each do |face|
		    file.write face.normal.to_a.pack("FFF")

		    face.points.each do |point|
			file.write point.to_a.pack("FFF")
		    end

		    file.write "\0\0"
		end
	    end
	end
    end

    def initialize(faces, min:nil, max:nil, name:nil)
	@faces = faces
	@max = max
	@min = min
	@name = name
    end

    # @!attribute minmax
    #   @return [Array]  the min and the max
    def minmax
	[min, max]
    end

    # Write the entire model to the given file
    # @param filename   [String]	The path to write to
    # @param format	    [Symbol]    Pass :ascii to write an ASCII formatted file, and :binary to write a binary file
    def write(filename, format=:binary)
	self.class.write(filename, faces, format)
    end
end