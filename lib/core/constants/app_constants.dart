

class AppConstant{
static int language = 0;

static int mobileNumberLength = 16;
static int passwordLength = 16;
static int emailAddressLenght = 100;
static int fullnameLength = 50;

static final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
}