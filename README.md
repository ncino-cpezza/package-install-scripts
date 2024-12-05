# Package Install Scripts

## Generate the Install package files

Using a CSV file, it will contain the headers of the following:

- Name
- Package Generation
- Password
- Version Id
- Namespace
- Version Number

Then each new line will contain the package that has a new version that is updated or net new. The key item in this file will be the Package Generation which will contain either 1GP or 2GP. Each are installed using different techniques from salesforce. 1GP is installed with package.xml. While 2GP is installed using salesforce CLI.

By placing a file with the name `installLinks.csv` in the root of this directory you can run a script to build all install files needed to run the install script.

Running the below script will generate the install packages using the csv method above.

```bash
pnpm run perform:generate
```

## Perform Installation

Now that the packages have been generated in the folders, run the below command to kick off the installation. Remember this can take anywhere from 4-5 hours and make sure the computer you are running this from does not fall asleep or turnoff.

The first part will install the 1GP packages, this has a timeout of 5 hours. Then each of the 2GP packages have a timeout of 30 mins but they should not take very long to install.

Run the below command to kick this off.

```bash
pnpm run perform:install
```

Once this is run you will be prompted to provide 2 things.

1. Access Token
2. Instance URL

To get both of these items you will need to log into the org you wish to install to and open Developer Console.

1. Open up Developer Console > Execute Anonymous
2. Paste the below snippet of code
```java
System.debug('Instance URL');
System.debug(URL.getOrgDomainUrl());
System.debug('Access Token');
System.debug(UserInfo.getOrganizationId() + '!'+ UserInfo.getSessionId().substringAfter('!'));
```
3. then click open log and then click execute.
4. Once the debug log opens in the bottom left click debug only and you should see 4 lines that look similar to below
```java
13:28:46:001 USER_DEBUG [1]|DEBUG|Instance URL
13:28:46:004 USER_DEBUG [2]|DEBUG|https://testorgurl.my.salesforce.com
13:28:46:004 USER_DEBUG [3]|DEBUG|Access Token
13:28:46:004 USER_DEBUG [4]|DEBUG|00DHo00001182GyMAI!AQ8AQNZfZIjF1psQqAaklCL2SYw8OXDg3b8bbaOi3SjJCxod5c237OrR6W1q8mzfMLLNrj7NeHlfigZS7yXNFBevJfyAmtk2
```
5. You will use line 2 and 4 for the inputs.

Once you have answered the prompts then the script will begin.

- It will first ensure authentication
- Then will run 1GP installs
- Then will run 2GP installs
