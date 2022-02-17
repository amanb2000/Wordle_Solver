

function get_remaining_words(not_in_str::Regex, known_pos_in,
    known_not_pos, words; verbose=false)

	"""
	not_in_str = r"[udiobglcfm]" # Greys
	known_pos_in = [('s',1), ('h',2), ('a',3), ('e', 5)] # Greens
	known_not_pos = [('a',1), ('a',2), ('e',4)] # Yellows
	words = readlines("words5.txt") # Possible "answer" words.
	"""

	# Eliminating words that use illegal letters
	if not_in_str != r""
		words_mask = get_mask_eliminate(words, not_in_str)

		words = words[words_mask]
	end
	if verbose
		println("After illegal letters: ", length(words))
	end

	# Screening for words that follow the known position rule
	local re_string = ""
	local k = 1 # which element of `known_pos_in` we are on
	for i = 1:5
		if k<=length(known_pos_in)
			if known_pos_in[k][2] == i
				re_string *= known_pos_in[k][1]
				k = k+1
			else
				re_string *= "[a-z]"
			end
		else
			# add an "[a-z]" to the string
			re_string*="[a-z]"
		end
	end



	if length(known_pos_in) > 0
		re = Regex(re_string)
		words_mask = get_mask_search(words, re)
		words = words[words_mask]
	end

	if verbose
		println("After known position: ", length(words))
	end

	# Eliminating all words that have characters where we know they should not be
	re_string = ""
	for tup in known_not_pos
		num = tup[2]
		c = tup[1]

		re_string*="("

		for i = 1:5
			if i == num
				re_string*=c
			else
				re_string*="[a-z]"
			end
		end
		re_string*=")|"
	end



	if length(known_not_pos) > 0
		re = Regex(re_string[1:end-1])
		words_mask = get_mask_eliminate(words, re)
		words = words[words_mask]
	end
	if verbose
		println("After known NOT position: ", length(words))
	end



	# Eliminating all words that don't have characters we know they should have.
	contains::Array{Char} = [x[1] for x in known_not_pos]

	if length(contains) > 0
		word_mask = falses(length(words))

		for i = 1:length(words)
			d = [x in words[i] for x in contains]
			if sum(d) == length(d)
				word_mask[i] = true
			end
		end

		words = words[word_mask]
	end
	if verbose
		println("After known NOT position's LETTERS: ", length(words))
	end

	return words, length(words)
end


function get_mask_eliminate(words, re)
	# Function to get a mask that eliminates all words matching with `re`
	words_mask = trues(length(words))
	for i = 1:length(words)
		if occursin(re, words[i])
			words_mask[i] = false
		end
	end
	return words_mask
end

function get_mask_search(words, re)
	# Function to get a mask that preserves only words matching with `re`
	words_mask = falses(length(words))
	for i = 1:length(words)
		if occursin(re, words[i])
			words_mask[i] = true
		end
	end
	return words_mask
end


function get_new_constraints(guess::String, truth::String, not_in_str::String, known_pos_in, known_not_pos)
    not_in_str_ = deepcopy(not_in_str)
    known_pos_in_ = convert(Vector{Tuple}, deepcopy(known_pos_in))
    known_not_pos_ = convert(Vector{Tuple}, deepcopy(known_not_pos))

    for i = 1:length(guess)
        if !(guess[i] in truth)
            not_in_str_ *= guess[i]
        elseif guess[i] == truth[i]
            h = (guess[i], i)
            push!(known_pos_in_, h)
        else
            h = (guess[i], i)
            push!(known_not_pos_, h)
        end
    end

	unique!(known_pos_in_)
	unique!(known_not_pos_)


    return not_in_str_, known_pos_in_, known_not_pos_
end

function how_good_is_guess(guess, truth, cur_size, not_in_str::String, known_pos_in, known_not_pos, words)
    # get new constraints given the guess
    not_in_str_, known_pos_in_, known_not_pos_ = get_new_constraints(guess, truth, not_in_str, known_pos_in, known_not_pos)

	ree = r""

	if length(not_in_str) > 0
	    ree = Regex("["*not_in_str*"]")
	end

    _, new_size = get_remaining_words(ree, known_pos_in_, known_not_pos_, words)

    return cur_size-new_size
end
