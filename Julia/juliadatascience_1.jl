function grades_array()
    name = ["Bob", "Sally", "Alice", "Hank"]
    age = [17, 18, 20, 19]
    grade_2020 = [5.0, 1.0, 8.5, 4.0]
    (; name, age, grade_2020)
end

grades_array()

using DataFrames
names = ["Sally", "Bob", "Alice", "Hank"]
grades = [1, 5, 8.5, 4]

df = DataFrame(; names=names, grade_2020 = grades)