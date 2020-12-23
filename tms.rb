require 'yaml'	#Requests additional Ruby libraries needed for the tool to work.
require 'date'
require 'FileUtils'
require 'io/console'
$currentpwd = Dir.pwd	#Sets $currentpwd to the current working directory (from which the script was executed). Will be used to navigate folders.

#------------------------------------- DEBUG TOGGLE BELOW. \/ Changing anything above this line may cause the program to become unstable.
debugToggle = false	#<--- DEBUG TOGGLE! Set this value to 'true' to enable debug mode if you've been told to do so. Don't forget to set it back to 'false' after the user file generation is completed!
#------------------------------------- DEBUG TOGGLE ABOVE. /\ Chnaging anything below this line may cause the program to become unstable.

if debugToggle == false	#If debug mode is enabled, will display a warning message, skip log in, and log in as a fake admin account.
	$logstatus = "out"
else
	$logstatus = "in"
	$currentuser = "DebugUser"
	$currenttype = "admin"
	puts ""
	puts "\t--- WARNING: DEBUG MODE HAS BEEN ENABLED! ---"
	puts "This allows the program to create a user with administrator privileges without the need for the password of an existing admin user by using a built-in debug account."
	puts "As a security measure, the program will not be usable for any purposes other than creating this administrator account (which includes its intended use) while debug mode is active."
	puts ""
	puts "If you have been told to enable debug mode in order to generate the 'users.yml' file and create the first administrator account, please proceed and create the account, then close the program and disable the debug mode again."
	puts "Otherwise, please close the program, and set the 'debugToggle' to 'false' in the file 'tms.rb' by opening it in Notepad or any text editing tool of your choice, to prevent unathorized access and unexpected behavior."
	puts "\t--- Thank you for understanding. Please proceed with caution! ---"
end

class User	#The class to store users.
	def initialize(username, password, acctype)
		@username = username
		@password = password
		@acctype = acctype
	end
	def listusers	#Used to display a list of registered users.
		puts "Name: #{@username}\tAccess privileges: #{@acctype}"
	end
	def readnew	#Used to read the info of a newly registered user.
		puts ""
		puts "\nThe user account '#{@username}', with the access privileges of #{@acctype}, has been created successfully."
		puts "You may now log in."
	end
	def checkadmin	#Used in collaboaration with the method checkadmin2 to see if there's an admin account registered with the passowrd $adminpasswordtest (used during registration of a new admin).
		if @password == $adminpasswordtest and @acctype == "admin"
			$adminpasswordexist = 1	#If that admin password exists, sets this to 1.
		end
	end
	def logincheck	#Used in collaboaration with the method logincheck2 to see if the data entered during login is valid (if that user exists and their password is correct).
		if @username == $loginusername and @password == $loginpassword
			$credentialsvalid = 1	#If validation is successful (user exists with the correct password) sets this to 1.
		end
	end
	def determineusertype	#Used in collaboaration with the method determineusertype2 to see if the user loggin in is an admin or a student.
		if @username == $loginusername and @acctype == "admin"
			$currenttypevar = 1	#If the user name logging in is an admin, sets this to 1. Otherwise, the program just assumes that whoever is logging in is a student.
		end
	end
	def checkusername	#Used in collaboaration with the method checkusername2 to see if a username is already taken or not during registration.
		if @username == $newusername
			$usernametaken = 1	#If a username is taken, sets this to 1.
		end
	end
end
class Numeric	#Creates the to_s26 method that will be used in order to convert numbers into letters of the English alphabet.
  Alpha26 = ("A".."Z").to_a
  def to_s26
    return "" if self < 1
    s, q = "", self
    loop do
      q, r = (q - 1).divmod(26)
      s.prepend(Alpha26[r]) 
      break if q.zero?
    end
    s
  end
end
class String	#Creates the to_i26 method that will be used in order to convert letters into numbers (according to their order in the alphabet).
  Alpha26 = ("A".."Z").to_a
  def to_i26
    result = 0
    capitalize!
    (1..length).each do |i|
      char = self[-i]
      result += 26**(i-1) * (Alpha26.index(char) + 1)
    end
    result
  end
end

if File.exist?("#{$currentpwd}/users/users.yml") == true	#Checks if the users.yml file that stores all users exists.
	loadusers = File.read("#{$currentpwd}/users/users.yml")	#If it does, load them into the User class.
	$users = YAML::load(loadusers)
elsif File.exist?("#{$currentpwd}/users/users.yml") == false and debugToggle == true	#If it doesn't, but debug mode is enabled, create a new $users array ready to accept new users.
	$users = Array.new
else	#Otherwise, display an error and terminate the program.
	puts ""
	puts "CRITICAL ERROR: The file '/users/users.yml' is corrupt or does not exist!"
	puts "This tool can not run without this file and at least one user with administrative privileges stored in it."
	puts "Please, open the file 'tms.rb' in Notepad or any text editor of your choice, set the 'debugToggle' to 'true', save and close the text editor, and start the program again in order to generate the file and create the first administrator account. Afterwards, set the 'debugToggle' to 'false' again."
	puts "We apologize for this inconvenience."
	puts "The program will now terminate."
	$mainchoice = "terminate"
end

def mainmenu	#Defines the main menu. Some values are displayed depending on what type of user is logged in.
	puts "You can:"
	puts "Type 'View tests' to see a list of all available tests."
	if $currenttype == "admin"
		puts "Type 'Create test' to create a new test."
		puts "Type 'View results' to view a student's test results."
	else
		puts "Type 'Take test' to take one of the available tests."
		puts "Type 'View results' to view all your test results."
	end
	puts "Type 'Log out' to log out and switch users."
	puts "Or type 'Quit' or 'Exit' to log out and close the program."
	print "Choice: "
	$mainchoice = gets.chomp.downcase
end
def loginscreen	#Defines the log in screen.
	print "Username: "
	$loginusername = gets.chomp
	print "Password (for security reasons, the password will not be displayed as you type): "
	$loginpassword = STDIN.noecho(&:gets).chomp	#Obfuscates the password being entered by not displaying the chracters that are being typed in.
	logincheck2	#Calls the logincheck2 method to see if the user exists and a valid password was entered.
end
def viewtests	#Displays a list of avaialbe tests.
	puts ""
	puts "Here's a list of all available tests:"
	puts "Name/topic\t-\tSubject\t-\tCreated by\t-\tCreated on"
	IO.foreach("#{$currentpwd}/questions/testlist.txt") {|line|print(line)}	#Each individual test info is stored on its own line as a string in this file.
	sleep(3)
end
def checkadmin2	#Applies the checkadmin class method to each object in the User class, to test if an admin with a password entered in $adminpasswordtest exists. Used during registration of a new admin.
	for x in 0 .. $users.length-1
		$users[x].checkadmin
	end
	if $adminpasswordexist == 1
		$adminpasswordexistvar = 1
	else
		$adminpasswordexitvar = 0
	end
end
def logincheck2	#Applies the logincheck class method to each object in the User class, to test if the user currently logging in exists and entered the correct password.
	for x in 0 .. $users.length-1
		$users[x].logincheck
	end
	if $credentialsvalid == 1
		$credentialsvalidvar = 1
	end
end
def determineusertype2	#Applies the determineusertype class method to each object in the User class, to determine whether the user logging in is an admin or a student.
	for x in 0 .. $users.length-1
		$users[x].determineusertype
	end
	if $currenttypevar == 1
		$currenttype = "admin"
	else
		$currenttype = "student"
	end
end
def checkusername2	#Applies the checkusername class method to each object in the User class, to test if a username is already taken when a new user is registering.
	for x in 0 .. $users.length-1
		$users[x].checkusername
	end
	if $usernametaken == 1
		$usernametakenvar = 1
	else
		$usernametakenvar = 0
	end
end
def readquestion	#Reads the questions and their answers out of a test file. In the file, questions are stored this way: Each test is its own file (the file name is the name of the test). Each line is one question and its answer in this format: question;{hash of answers, with a value of T or F to denote which answer is correct}.
	currentline = IO.readlines($questionfile)[$readline - 1]	#Read the line of the current question.
	$questiontoprint, answerhashread = currentline.split(";")	#Use ; to separate the question from he answer hash. Whatever is before the ; symbol becomes the variable $questiontoprint, whatever is after it becomes answerhashread.
	$answerhash = eval(answerhashread)	#Converts the hash into an actual hash.
end
def resultprinter	#Used to print the file containing all the reuslts of a specfic student.
	resultsfile = File.open("#{$currentpwd}/results/#{$viewname}.txt", 'r')
	File.readlines(resultsfile).each do |line|	#Each line in the file is one test result. Results are stored in the following format: test topic;student's answers|how many questions (and the percentage) did the student answer correctly~when did the student take the test.
		currenttopic, therest1 = line.split(";")
		currentanswerchoice, therest2 = therest1.split("|")
		currentanswerchoice = currentanswerchoice[0...-2]
		currentcorrectcounter, currentnewtestdate = therest2.split("~")
		puts "Topic: #{currenttopic}\t-\tChosen answers: #{currentanswerchoice}\t-\tCorrect answers: #{currentcorrectcounter}\t-\tTest taken on: #{currentnewtestdate}"
	end
end
def resultprinterstudent	#Used to print the file containing all the results of the student that's currently logged in. Almost the same as the above method.
	resultsfile = File.open("#{$currentpwd}/results/#{$currentuser}.txt", 'r')
	File.readlines(resultsfile).each do |line|
		currenttopic, therest1 = line.split(";")
		currentanswerchoice, therest2 = therest1.split("|")
		currentanswerchoice = currentanswerchoice[0...-2]
		currentcorrectcounter, currentnewtestdate = therest2.split("~")
		puts "Topic: #{currenttopic}\t-\tChosen answers: #{currentanswerchoice}\t-\tCorrect answers: #{currentcorrectcounter}\t-\tTest taken on: #{currentnewtestdate}"
	end
end

unless $mainchoice == "terminate" or $currentuser == "DebugUser"	#Welcome text. Skipped if debug mode is enabled or the program has been told to terminate prematurely.
	puts ""
	puts "Welcome to the Test Management System!"
	puts "You must login or register in order to proceed with taking or creating tests."
end
until $mainchoice == "quit" or $mainchoice == "exit" or $mainchoice == "terminate" or $currentuser == "DebugUser"	#Repeats the login screen and afterwards the main menu with all the testing functionalities, until the user quits or the program is/was told to terminate. Skipped if debugmode is enabled.
	until $logstatus == "in" or $mainchoice == "quit" or $mainchoice == "exit" or $mainchoice == "terminate"	#Keep repeating the log in screen until the user wants to quit or logs in successfully.
		puts ""
		puts "Type 'Log in' to log in."
		puts "Type 'Register' to register as a new user."
		puts "Type 'List' to list all registered users who have used this tool before."
		puts "Or type 'Quit' or 'Exit' to leave."
		print "Choice: "
		logchoice = gets.chomp.downcase
		if logchoice == "login" or logchoice == "log in"	#If the user chose to log in.
			puts ""
			puts "You have chosen to log in."
			loginscreen	#Calls the loginscreen method to display the log in screen.
			until $credentialsvalidvar == 1	#If, as a result of the method logincheck2 the program determined that the user does not exist or the password was incorrect, keep repeating this.
				puts ""
				puts ""
				puts "Incorrect password, or an account with such username does not exist."
				puts "Please try again, or close the program to leave."
				loginscreen
			end
			$currentuser = $loginusername	#Tells the program what is the name of the user that logged in successfully, and what their account type is.
			$currenttype = ""	#Resets the variable, so that the script works again if the user logs out and another wants to log in.
			$currenttypevar = 0
			determineusertype2	#Uses the method to determine whether the user logging is an admin or a student.
			$logstatus = "in"
			puts ""
			puts ""
			puts "Login successful!"
		elsif logchoice == "register" or logchoice == "new" or logchoice == "reg"	#If the user chooses to register a new account.
			adminpasswordtry = 5	#Resets the variables for next registration.
			$usernametaken, $usernametakenvar = 0, 0
			puts ""
			puts "You have chosen to register a new user."
			print "Username: "
			$newusername = gets.chomp
			checkusername2	#Checks if the username is laready taken.
			until $usernametakenvar == 0	#If the username is already taken.
				$usernametaken = 0
				puts ""
				puts "That user name is already taken. Please choose a different one."
				print "Username: "
				$newusername = gets.chomp
				checkusername2
			end
			print "Password (for security reasons, the password will not be displayed as you type): "
			newpassword = STDIN.noecho(&:gets).chomp
			print "\nAccount type (admin/teacher or student): "
			newacctype = gets.chomp.downcase
				if newacctype == "teacher" or newacctype == "admin"	#Makes sure that if the user enters anything else other than admin or student, the program will default to student.
					newacctype = "admin"
				else
				newacctype = "student"
				end
			if newacctype == "admin"	#To register a new admin, the user must enter the password of an existing admin user, to prevent anyone from just giving themselves administrator privileges. This is why debug mode is necessary for the first run.
				$adminpasswordexist, $adminpasswordexistvar = 0, 0	#Resets the variables for next registration.
				puts ""
				puts "As an added security measure, in order to register a new user with administrator prvileges, you must now enter a password of any existing administrator."
				print "Admin password (for security reasons, the password will not be displayed as you type): "
				$adminpasswordtest = STDIN.noecho(&:gets).chomp
				checkadmin2	#Tests the password.
				until $adminpasswordexistvar == 1 or adminpasswordtry == 1	#The user has 5 tries to enter the correct password before the program shuts down.
					adminpasswordtry = adminpasswordtry - 1
					puts ""
					puts ""
					puts "Invalid password. #{adminpasswordtry} try/tries remaining."
					print "Try again: "
					$adminpasswordtest = STDIN.noecho(&:gets).chomp
					checkadmin2
				end
			end
			if adminpasswordtry == 1 and newacctype != "student"	#If the user fails 5 times.
				puts ""
				puts ""
				puts "ERROR: Access denied - Admin account creation failed after 5 tries. Unauthorized access detected."
				puts "As a security measure, the program will now terminate."
				$mainchoice = "terminate"
			else	#Pushes the newly created user into the User class and saves to database.
				user = User.new($newusername,newpassword,newacctype)
				$users.push(user)
				user.readnew
				File.open("#{$currentpwd}/users/users.yml", 'w') {
					|f|
					f.write($users.to_yaml)
					f.close()
				}
			end
		elsif logchoice == "list"	#Shows a list of users.
			puts ""
			puts "Here's a list of users stored in the database:"
			for x in 0 .. $users.length-1
				$users[x].listusers
			end
			sleep(3)
		elsif logchoice == "quit" or logchoice == "exit"
			$mainchoice = "quit"
		else	#Unknown command failsafe.
			puts ""
			puts "Unknown command."
		end
	end
	unless $mainchoice == "quit" or $mainchoice == "exit" or $mainchoice == "terminate"	#Keep showing the test environment until program is quit.
		puts ""
		puts "Welcome, #{$currentuser}, to the Test Management System!"
		puts "What would you like to do?"
		mainmenu
		if $mainchoice == "view tests" or $mainchoice == "tests"	#Shows a list of available tests.
			if File.exist?("#{$currentpwd}/questions/testlist.txt") == true
				viewtests	#Shows the list if the testlist file exists.
			else
				puts ""
				puts "No tests have been created yet."
			end
		elsif $mainchoice == "log out" or $mainchoice == "logout"	#Logs the user out.
			puts ""
			puts "Logging out..."
			puts ""
			$logstatus = "out"
		elsif $mainchoice == "create test" or $mainchoice == "create"	#Allows admins to create new tests.
			if $currenttype == "student"
				puts ""
				puts "You do not have sufficient privileges to create a new test."
			else
				puts ""
				puts "You have chosen to create a new test."
				puts "First, choose a test category/subject (e.g.: Physics, Literature, Philosophy, ...)."
				print "Subject: "
				newsubject = gets.chomp
				puts "What is the topic of your test (e.g.: Atoms, George Orwell, Philosophers of the Ancient Greece, ...)?"
				print "Topic: "
				newtopic = gets.chomp.to_s
				if Dir.exist?("#{$currentpwd}/questions/#{newsubject}") == false	#Tests are stored in the following manner: The file name is the name/topic of the test. Each test on a sepcific subject is stored in a folder named after the subject. This folder is located in a folder called tests. This if statement checks if the subject folder already exists, and if it does not, creates it.
					FileUtils.mkdir_p("#{$currentpwd}/questions/#{newsubject}")
				end
				f = File.open("#{$currentpwd}/questions/#{newsubject}/#{newtopic}.txt", 'a')	#Creates the test file. Technically, aslo allows adding new questions to an existing test, though that is not mentioned in the main menu.
				puts "How many questions will the test have?"
				print "Number of questions: "
				newnumber = gets.chomp
				puts ""
				puts "Now, let's start writing in the questions and their answers:"
				currentnumber = 1
				until currentnumber > newnumber.to_i	#Repeats the process of adding questions and answers until the current question number is greater than the number of total questions the test is supposed to have.
					print "\nQuestion #{currentnumber}: "
					question = gets.chomp.to_s
					f.print "#{question};"
					print "How many answers should this question have?: "
					newanswernumber = gets.chomp
					currentanswernumber = 1
					questionhash = Hash.new()	#Creates the answr hash.
					until currentanswernumber > newanswernumber.to_i	#Repests the process of adding answers until the current answer number is greater than the number of total answers the question is supposed to have.
						print "Answer #{currentanswernumber}: "
						answer = gets.chomp.to_s
						print "Is that the correct answer (Y/N)?: "
						correct = gets.chomp.capitalize
							if correct == "Y" or correct == "YES"	#Stores correct and incorrect answers as T or F. Technically allows multiple correct answers.
								correct = "T"
								else
								correct = "F"
							end
						questionhash["#{answer}"] = "#{correct}"	#Pushes the answer into the answer hash.
						currentanswernumber = currentanswernumber + 1	#Adds 1 to the current answer number.
					end
				currentnumber = currentnumber + 1	#Adds 1 to the current question number.
				f.print "#{questionhash}\n"	#Prints the answer hash into the test file.
				end
				puts ""
				puts "Your test on #{newtopic} has been saved."
				f.close()
				date = Time.new
				newdate = date.strftime("%d %B %Y, %H:%M")	#saves the test file. The questions and their answers are each on new line. Also adds a timestamp of the test creation date into the file.
				f2 = File.open("#{$currentpwd}/questions/testlist.txt", 'a')
				f2.puts "#{newtopic}\t-\t#{newsubject}\t-\t#{$currentuser}\t-\t#{newdate}"
				f2.close()
				sleep(3)
			end
		elsif $mainchoice == "view results" or $mainchoice == "results"	#Displays test results.
			if $currenttype == "admin"	#If the current user is an andmin, allows the user to choose which student's results do they want to see.
				puts ""
				puts "Enter the username of a student whose results you would like to see."
				print "Name: "
				$viewname = gets.chomp
					if File.exist?("#{$currentpwd}/results/#{$viewname}.txt") == true
						puts ""
						puts "Here are the results of all tests taken by #{$viewname}, in chronological order:"
						resultprinter	#Prints a specific student's results.
						sleep(5)
					else
						puts ""
						puts "A student with that username does not exist, or has not taken any tests yet."
					end
			else
				if File.exist?("#{$currentpwd}/results/#{$currentuser}.txt") == true
				puts ""
				puts "Here are the results of all the tests you have taken, in chronological order:"
				resultprinterstudent	#Prints the current user's results.
				sleep(5)
				else
					puts ""
					puts "You have not taken any tests yet."
				end
			end
		elsif $mainchoice == "take test" or $mainchoice == "test" or $mainchoice == "take"	#Allows students to take tests.
			if $currenttype == "admin"
				puts ""
				puts "ERROR: Only students are allowed to take tests."
			else
				puts ""
				puts "You have chosen to take a test."
				puts "Type the name of the test you would like to take (with proper capitalization), or type 'View tests' to see a list of available tests."
				print "Choice: "
				testchoice = gets.chomp
				unless testchoice == "view tests" or testchoice == "tests"
					puts "\nAnd what is the thest's subject (with proper capitalization, according to the test list, e.g. Physics, Literature, ...)?"
					print "Subject: "
					subjectchoice = gets.chomp
				end
				if testchoice.downcase == "view tests" or testchoice.downcase == "tests"	#Displays a list of available tests.
					if File.exist?("#{$currentpwd}/questions/testlist.txt") == true
						viewtests
					else
						puts ""
						puts "No tests have been created yet."
				end
				elsif File.exist?("#{$currentpwd}/questions/#{subjectchoice}/#{testchoice}.txt") == true	#Uses the requested subjectchoice and testchoice variables to find the test file in the folder structure.
					puts ""
					puts "Test file found. Loading..."
					sleep(4)
					puts ""
					puts "The test on '#{testchoice}' is now ready to begin."
					puts "Before starting, please be aware of the following things:"
					puts "1. There is no time limit to this test."
					puts "2. All answers are final. Once you answer a question, it is not possible to return to it later."
					puts "3. It is possible to retake the test, but your previous attempt will remain saved in the result history."
					puts "4. Please do not close the program while the test is in progress to prevent your results file from becoming corrupt. Once the test is in progress, it is not possible to cancel."
					puts ""
					puts "Are you sure you wish to begin (Y/N)?"
					print "Choice: "
					begintest = gets.chomp.downcase	#The user may cancel taking the test before it starts. If the user closes the program while a test is in progress, incomplete data will be saved, corrupting the file.
					if begintest == "y" or begintest == "yes"
						puts ""
						print "\nGood luck! Test starting in 3 "
						sleep(2)
						print "2 "
						sleep(1)
						print "1"
						puts ""
						sleep(1)
						correctcounter = 0	#Resets the variables before taking the test.
						currentquestioncounter = 1
						$readline = currentquestioncounter
						$questionfile = File.open("#{$currentpwd}/questions/#{subjectchoice}/#{testchoice}.txt", 'r')	#Loads the test file into memory.
						resultsfile = File.open("#{$currentpwd}/results/#{$currentuser}.txt", 'a')	#Loads the student's results file into memory.
						resultsfile.print "#{testchoice};"	#Prints the name of the test that the student is taking into the results file.
						totalquestions = (IO.readlines($questionfile).size).to_i	#Counts how many questions (lines) are in the test file, to generate the total amount of questions.
						until currentquestioncounter > totalquestions	#Repeats printing questions until all are answered.
							currentquestionpercentage = ((currentquestioncounter - 1) * 100) / totalquestions	#Calculates the percentage of how many questions have been answered.
							puts ""
							puts "Question #{currentquestioncounter.to_s} of #{totalquestions.to_s} (#{currentquestionpercentage.to_s}% done):"
							readquestion	#Reads the current question.
							print $questiontoprint	#Prints the current question.
							puts ""
							puts ""
							puts "Answers:"
							answernumber = 1	#Resets the variable before each question.
							$answerhash.each_key do |key|	#Prints the keys of the answer hash (the actual answers). Each answer is prefaced by a letter (A., B., C., ...)
								puts "#{answernumber.to_s26}. #{key}"
								answernumber = answernumber + 1
							end
							puts ""
							puts"------------------------"
							puts "Type the answer letter (A, B, C, ...) of the answer you want to mark as correct."
							print "Choice: "
							answerchoice = gets.chomp.capitalize
							realanswerchoice = (answerchoice.to_i26) - 1	#As the user is asked to just type the letter of the answer they want to mark as correct, this will convert the letter back into a number.
							if $answerhash.values[realanswerchoice] == "T"	#Checks if the value of the key that's in the position of the student's answer is T or F.
								correctcounter = correctcounter + 1	#If it's T, add 1 to the number of questions answered correctly.
							end
							resultsfile.print "#{answerchoice}, "	#Print which answer did the student pick into the results file.
							puts "Answer logged."
							puts ""
							currentquestioncounter = currentquestioncounter + 1
							$readline = currentquestioncounter	#Tells the program to read the next question (line) in the file when until loops.
						end
						puts "Test completed. All answers have been logged successfully. Returning to main menu."
						correctpercentage = (((correctcounter * 100).to_f) / totalquestions).round(2)	#Calculates the percentage of correct answers.
						resultsfile.print "|#{correctcounter} out of #{totalquestions} (#{correctpercentage}%)"	#Prints the correctness of the student's answers into the results file.
						testdate = Time.new
						newtestdate = newdate = testdate.strftime("%d %B %Y, %H:%M")	#Prints when the test was finished into the results file.
						resultsfile.print "~#{newtestdate}\n"
						$questionfile.close()
						resultsfile.close()
						sleep(3)
					else
						puts ""
						puts "Test cancelled. Returning to main menu."
						sleep(3)
					end
				else
					puts ""
					puts "A test with that name does not exist, or is part of a different subject."
				end
			end
		elsif $mainchoice == "quit" or $mainchoice == "exit" or $mainchoice == "terminate"	#If user chooses to quit, do nothing.
		else
			puts ""
			puts "Unknown command. Returning to menu."
			puts ""
		end
	end
end

if $mainchoice == "terminate" and $currentuser != "DebugUser"	#If debug mode is enabled, the whole until loop above is skipped and this is displayed instead.
elsif $currentuser == "DebugUser"	#If the program terminates itself, this is also skipped.
	puts ""
	puts "DEBUG MESSAGE: Generating 'users.yml' file. Please stand by..."
	sleep(3)
	puts ""
	puts "DEBUG MESSAGE: File generated successfully. Proceeding with admin registration..."
	puts ""
	puts "Type 'Log in' to log in."
	puts "Type 'Register' to register as a new user."
	puts "Type 'List' to list all registered users who have used this tool before."
	puts "Or type 'Quit' or 'Exit' to leave."
	puts "Choice: X"
	puts "DEBUG MESSAGE: Debug mode active. Forcing registration..."
	puts ""
	puts "You have chosen to register a new user."
	print "Username: "
	$newusername = gets.chomp
	print "Password (for security reasons, the password will not be displayed as you type): "
	newpassword = STDIN.noecho(&:gets).chomp
	puts "\nAccount type (admin/teacher or student): X"
	puts "DEBUG MESSAGE: Debug mode active. Forcing type admin..."
	newacctype = "admin"
	puts ""
	puts "As an added security measure, in order to register a new user with administrator prvileges, you must now enter a password of any existing administrator."
	puts "Admin password (for security reasons, the password will not be displayed as you type): X"
	puts "DEBUG MESSAGE: Debug mode active. Bypassing admin password requirement..."
	user = User.new($newusername,newpassword,newacctype)	#Creates and adds the new admin user into the database.
	$users.push(user)
	user.readnew
	FileUtils.mkdir_p("#{$currentpwd}/users")	#Creates the users folder.
	File.open("#{$currentpwd}/users/users.yml", 'w') {
		|f|
		f.write($users.to_yaml)
		f.close()
	}
	puts ""
	puts "DEBUG MESSAGE: Admin user added to file successfully. Proceeding with generating the initial folder structure. Please stand by..."
	FileUtils.mkdir_p("#{$currentpwd}/questions")	#Generates the folders 'questions' and 'results' so that tests and results can be saved.
	FileUtils.mkdir_p("#{$currentpwd}/results")
	sleep(3)
	puts ""
	puts "DEBUG MESSAGE: Folders generated successfully."
	puts "DEBUG MESSAGE: Program initialization complete. The program will now terminate. Please disable debug mode before starting the program again to avoid unexpected behavior."
else
	puts ""	#Farewell bidding.
	puts "Thank you for using the Test Management Tool."
	puts "Have a nice day!"
end
#Made by Patrik Zori, Copenhagen School of Design and Technology, BE-IT International A17, 2017.