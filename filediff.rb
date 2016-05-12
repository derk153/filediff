module FileDiffer
  class FileDiff

    def initialize(file1_path, file2_path)
      raise "File #{file1_path} not exist" unless File.exists?(file1_path)
      raise "File #{file2_path} not exist" unless File.exists?(file2_path)

      @file1 = File.readlines(file1_path).map!(&:strip)
      @file2 = File.readlines(file2_path).map!(&:strip)

      @matrix = Array.new(@file1.size + 1) { Array.new(@file2.size + 1) { 0 } }
    end

    # Returns Array of hashes of file comparing
    # {
    #   :type - operation type
    #   :value  -
    # }
    # pretty_print - (boolean) will print result after
    #
    # temporary compare only 2 files
    def compare(pretty_print=false)
      return if @file1.empty? || @file2.empty?

      fill_lcs_matrix
      result = compaq(build_diff_array)

      pretty_print(result) if pretty_print

      result
    end

    # Formatted print of diff_array
    def pretty_print(result)
      result.each_with_index do |line, index|
        puts "#{index+1}:\t #{type_to_sym(line[:type])}\t#{line[:value]}"
      end
    end

    private

    def fill_lcs_matrix
      @file1.each_with_index do |line1, i|
        i += 1
        @file2.each_with_index do |line2, j|
          j += 1

          if line1 == line2
            @matrix[i][j] = @matrix[i-1][j-1] + 1
          elsif @matrix[i-1][j] >= @matrix[i][j-1]
            @matrix[i][j] = @matrix[i-1][j]
          else
            @matrix[i][j] = @matrix[i][j-1]
          end
        end
      end
    end

    def build_diff_array(diff_array=[], i = nil, j = nil)
      i ||= @file1.size
      j ||= @file2.size

      if i > 0 && j > 0 && @file1[i-1] == @file2[j-1]
        build_diff_array(diff_array, i - 1, j - 1)
        diff_array << {type: :not_changed, value: @file1[i-1]}
      elsif j > 0 && (i == 0 || @matrix[i][j - 1] >= @matrix[i - 1][j])
        build_diff_array(diff_array, i, j - 1)
        diff_array << {type: :added, value: @file2[j-1]}
      elsif i > 0 && (j == 0 || @matrix[i][j - 1] < @matrix[i - 1][j])
        build_diff_array(diff_array, i - 1, j)
        diff_array << {type: :removed, value: @file1[i-1]}
      else
        ''
      end
    end


    def compaq(diff_array)
      diff_array.each_with_index do |e, i|
        next unless [:added, :removed].include? e[:type]
        next if e.empty?

        paired_elem_index = get_pair_index(diff_array, i)
        next unless paired_elem_index

        replace_str = ''
        replace_str << (diff_array[paired_elem_index][:type] == :added ? e[:value] : diff_array[paired_elem_index][:value])
        replace_str << '|'
        replace_str << (diff_array[paired_elem_index][:type] == :removed ? e[:value] : diff_array[paired_elem_index][:value])

        diff_array[i][:value] = replace_str
        diff_array[i][:type] = :changed
        diff_array[paired_elem_index] = {}
      end

      diff_array.delete_if(&:empty?)
    end

    def get_pair_index(diff_array, elem_index)
      return unless [:added, :removed].include? diff_array[elem_index][:type]
      diff_array.drop(elem_index + 1).each_with_index do |e, i|
        next if e.empty?
        return unless [:added, :removed].include? e[:type]
        return i + elem_index + 1 if e[:type] != diff_array[elem_index][:type]
      end
      nil
    end

    def type_to_sym(type)
      case type
        when :changed
          '*'
        when :removed
          '-'
        when :added
          '+'
        else
          ' '
      end
    end

  end
end