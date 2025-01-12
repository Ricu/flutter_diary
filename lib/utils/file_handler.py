# Two kinds of data to handle:
# 1. Audio recording to be saved and stored for later use / reference
# a. File name should contain the date, its content is about. (YYYY-MM-DD)
# b. File name should contain the date and time of recording (YYYY-MM-DD-HH-MM-SS)
# c. All audio recordings should be in an sensible location (e.g. documents folder)
# d. All audio recordings should be subfolders of the main folder depending on the day the content is about (i.e. point a.)

# 2. The information about the transcribed and processed recording
# a. Each day is one entry (if there has been created)
# b. Nested structure can be flattened if required if required (e.g. for SQL)
# c. Information should be stored either in a SQL or NoSQL database or in a json in the same folder as the audio recording
# "2025-01-11" -> "category_a" -> "text" 
#              |
#              -> "category_b" -> "text"
#                              |
#                              -> "additional_information_a"