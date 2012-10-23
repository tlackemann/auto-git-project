#!/usr/bin/perl

# Prime working directory
$www = "/www/projects";
# Our git satellite folder
$git = "/git";


print "Enter a project name: ";
$input = <STDIN>;
chomp ($input);

print "Setup project for rails hosting? (y/n): ";
$rails = <STDIN>;
chomp($rails);

print "This will create a folder and git-repo called '$input'\nProceed? (y/n): ";
$confirm = <STDIN>;
chomp($confirm);

if(lc($confirm) eq 'yes' || lc($confirm) eq 'y') {

	# Create a new project

	if(lc($rails) eq 'yes' || lc($rails) eq 'y') {
		# The project is rails so we need to run a new project from the command line
		print "\nCreating new rails project '$input'...\n";
		system("cd $www && rails new $input");
	} else {
		# Not a rails project so we'll just put in a blank php file for now
		print "\nCreating new folder '$input'...\n";
		mkdir "$www/$input";
		system("cd $www/$input && touch index.php");
	}

	print "\nCreating git repository...\n";
	mkdir "$git/$input.git";
	system("cd $git/$input.git && git --bare init");
	
	print "\nSetting up git...\n";
	system("cd $www/$input && git init && git add -A && git commit -am 'System generated initial import of files' && git remote add hub $git/$input.git && git push hub master");
	
	print "\nAdding remote to prime and pushing...";

	print "\nSetting up hooks...\n";

	print " - Adding hook into prime (post-commit)\n";
	open(FILE, ">$www/$input/.git/hooks/post-commit") or die "Couldn't open file\n\n";
	print FILE "#!/bin/sh\n\necho\necho \"**** pushing changes to Hub ****\"\necho\n\ngit push hub";
	close(FILE);
	system("cd $www/$input/.git/hooks && chmod 755 post-commit");	
	
	print " - Adding hook into hub (post-update)\n";
	open(FILE, ">$git/$input.git/hooks/post-update") or die "Couldn't open file\n\n";
	if(lc($rails) eq 'yes' || lc($rails) eq 'y') {
		# if the file is rails, issue a bundle install command each time for now
		print " - Adding 'bundle install' command\n";
		$bundle = "bundle install";
	} else {
		$bundle = '';
	}
	print FILE "#!/bin/sh\n\necho\necho \"**** pulling changes into prime ****\"\necho\n\ncd $www/$input || exit\nunset GIT_DIR\ngit pull hub master\n$bundle\nexec git-update-server-info";
	close(FILE);
	system("cd $git/$input.git/hooks && chmod 755 post-update");	
	
	print ("Done.\n\nTo grab this project, run the following command:\n\n");
	print ("     >  git clone ssh://root\@216.67.225.174:100$git/$input.git $input\n");
	if(lc($rails) eq 'yes' || lc($rails) eq 'y') {
		print("     >  cd $input && bundle install\n\n");
	}
} else {
	print "\nExiting...\n";
}
