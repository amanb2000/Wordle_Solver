using Distributed
using ProgressMeter
"""
Program that finds the best word to guess given some constraints, a set of
possible word answers, and a set of possible word guesses.
"""


include("get_remaining_words.jl")

println("\nNumber of threads: ", Threads.nthreads())

answer_words = readlines("answers.txt")
allowed_words = readlines("allowed_words.txt");

println("Number of GUESS words: ", length(allowed_words))
append!(allowed_words,answer_words)
unique!(allowed_words)
println("Number of GUESS words: ", length(allowed_words))
println("Number of ANSWER words: ", length(answer_words))


not_in_str = ""
known_pos_in = []
known_not_pos = []

# not_in_str = "udio"
# known_pos_in = []
# known_not_pos = [('a',1)]

# println("\nOLD CONSTRAINTS AFTER 'audio' GUESS")
# println("not_in_str: ", not_in_str)
# println("known_pos_in: ", known_pos_in)
# println("known_not_pos: ", known_not_pos)
# println()




ree = r""
if length(not_in_str) > 0
    ree = Regex("["*not_in_str*"]")
end

feasible_answer_words, cur_size = get_remaining_words(ree, known_pos_in, known_not_pos, answer_words)
feasible_guess_words, cur_size = get_remaining_words(ree, known_pos_in, known_not_pos, allowed_words)
# Expected reduction for each word.
expected_reduction = zeros(length(feasible_guess_words))# Expected reduction for each word.

println("Number of remaining ANSWER words: ", length(feasible_answer_words))
println("Number of remaining GUESS words: ", length(feasible_guess_words))
@showprogress for i=1:length(feasible_guess_words)
# for j = 1:length(feasible_words)
Threads.@threads for j = 1:length(feasible_answer_words)
    # words[i] : guess
    # words[j] : truth

    expected_reduction[i] += how_good_is_guess(feasible_guess_words[i], feasible_answer_words[j], cur_size, not_in_str, known_pos_in, known_not_pos, feasible_answer_words)/(length(feasible_guess_words)+0.0)
end
end

word_order = sortperm(expected_reduction, rev=true)
sorted_reduction = expected_reduction[word_order]
sorted_words = feasible_guess_words[word_order]

println("Expected reductions: Top 5 Values")
println(sorted_reduction[1:min(5,length(sorted_reduction))])

println("\nExpected reductions: Top")
for i = 1:min(50,length(sorted_words))
    println(sorted_words[i]," -- ", sorted_reduction[i])
end
