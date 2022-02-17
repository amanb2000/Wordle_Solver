""" Script to solve for the relative probabilities of guess 
patterns based on current information. 
"""

# Letters that are NOT in the word.
not_in_str = r"[udiobglcfm]"

known_pos_in = [('s',1), ('h',2), ('a',3), ('e', 5)] # Letters where the position is known.
known_not_pos = [('a',1), ('a',2), ('e',4)] # Letters that are in the word, but NOT in the position.

guess_form = r"[a-z][a-z]a[a-z][a-z]"

words = readlines("words5.txt");

println("Number of possible words: ",length(words))


""" First: we eliminate words from the list 
that violate our constraints
"""
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

# Eliminating words that use illegal letters
words_mask = get_mask_eliminate(words, not_in_str)

words = words[words_mask]

println("Number of possible words after illegal character elimination: ",length(words))


# Screening for words that follow the known position rule
re_string = ""
k=1 # which element of `known_pos_in` we are on
for i = 1:5
	if k<=length(known_pos_in) && known_pos_in[k][2] == i
		global re_string *= known_pos_in[k][1]
		global k = k+1
	else
		# add an "[a-z]" to the string
		global re_string*="[a-z]"
	end
end

re = Regex(re_string)
println("REGEX: Known positions: ",re);

words_mask = get_mask_search(words, re)
words = words[words_mask]
println("Number of possible words after screening for known position characters: ", length(words))



# Eliminating all words that have characters where we know they should not be

re_string = ""
for tup in known_not_pos
	num = tup[2]
	c = tup[1]

	re_string*="("

	for i = 1:5
		if i == num
			global re_string*=c
		else
			global re_string*="[a-z]"
		end
	end
	global re_string*=")|"
end
println(re_string)
re = Regex(re_string[1:end-1])


println("REGEX: Known NOT positions: ",re);

words_mask = get_mask_eliminate(words, re)
words = words[words_mask]
println("Number of possible words after screening for known NOT position characters: ", length(words))


# Eliminating all words that don't have characters we know they should have.

contains = [x[1] for x in known_not_pos]
println(contains)

word_mask = falses(length(words))

for i = 1:length(words)
	d = [x in words[i] for x in contains]
	if sum(d) == length(d)
		word_mask[i] = true
	end
end

words = words[word_mask]
println("\nNumber of possible words after ALL CONSTRAINTS: ", length(words))

f = open("potentials.txt", "w")
for i in words
	println(f, i)
end

words_mask = get_mask_search(words, guess_form)
words = words[words_mask]
println("Number of possible words after screening for GUESS PATTERN: ",length(words))


f = open("potentials_guess.txt", "w")
for i in words
	println(f, i)
end
















