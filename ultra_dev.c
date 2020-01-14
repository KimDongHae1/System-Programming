#include <linux/gpio.h> 
//GPIO를 사용하기 위해 사용 모든 GPIO를 unsigned integer로 나타낸다. 
//gpio는 사용하기 전에 지정되어야 한다. GPIO 드라이버가 여전히 글로벌 GPIO 숫자 공간을 참조할 때 사용됨
#include <linux/init.h> 
// mknod를 사용하기 위해 사용된다.
#include <linux/module.h> 
// 모듈에 적재하기 위해 사용, 제거하기 위해 사용한다.
// module_init, module_exit에 사용된다.
#include <linux/delay.h> 
// trig부분에 일정 시간의 전류를 부여하기 위해 delay.h를 사용하였다.
#include <linux/fs.h> 
// 파일 시스템 처럼 사용하기 위해 사용하였다. udelay()
#include <linux/uaccess.h> 
// copy_to_user, copy_from_user등을 사용하기 위한 라이브러리
// unregiter_chrdev, register_chrdev등에도 사용


#define GPIOOUT 12 //trig
#define GPIOIN 1 //echo
#define DEV_NAME "ultra_dev"
// 파일 이름
#define DEV_NUM 243
// 파일 번호

MODULE_LICENSE("GPL");

static int temp;
static int state;

int ultra_open(struct inode *pinode, struct file *pfile){

 printk(KERN_ALERT "OPEN ultra_dev\n");
 // 커널 출력(printk)
 gpio_request(GPIOIN,"GPIOIN");
 // 요청하는 것이다.
 gpio_direction_input(GPIOIN);
 // gpio를 지정해주는 부분. 전류가 들어오는 부분
 gpio_request(GPIOOUT,"GPIOOUT");
 gpio_direction_output(GPIOOUT,0);
 // gpio를 지정해주는 부분. 전류가 나가는 부분
 return 0;
}

int ultra_close(struct inode *pinode, struct file *pfile){
 printk(KERN_ALERT "RELEASE ultra_dev\n");
 return 0;
}

ssize_t ultra_write(struct file *pfile,const char __user *buffer, size_t length, loff_t *offset)
{
 printk("Write ultra drv\n");
 
 gpio_set_value(GPIOOUT,0); 
 gpio_set_value(GPIOOUT,1);
 // GPIO OUT이라고 지정해준 핀의 값을 
 udelay(30);
 gpio_set_value(GPIOOUT,0);
 //트리거에서 초음파를 쏘게 한다. 1일 경우 초음파 출력 0 -> 1(10마이크로 초) -> 0  _|-|_ 이렇게 생긴 초음파 발생.
 return 0;
}

ssize_t ultra_read(struct file *pfile, char __user *buffer, size_t length, loff_t *offset){

 //printk("Read simple ultra drv\n");
 state=gpio_get_value(GPIOIN);
 // gpio의 상태를 준다.
 if(state==0){
	temp=0;
	copy_to_user(buffer,&temp,4);
	//kernel -> 응용프로그램 자원 전달
	//copy_from_user: 
	//응용프로그램 -> kernel으로 자원 전달
	
 }
 else if(state==1){
	temp=1;
	copy_to_user(buffer,&temp,4);
	
 }
 else
 	return -1;
 //implemented by polling manner. send stopflag to main app if state==1

 return 0;

}

 // 이 부분이 그래서 사용 가능하다!!
struct file_operations fop={
 .owner = THIS_MODULE,
 .open = ultra_open,
 .release = ultra_close,
 .write = ultra_write,
 .read = ultra_read,
};

int __init ultra_init(void){
 printk(KERN_ALERT "INIT ultra\n");
 register_chrdev(DEV_NUM, DEV_NAME, &fop);
 //파일 형식으로 만든다.(숫자, 이름, 포인터)
 //fs.h 라이브러리에 있다.
 return 0;

}

void __exit ultra_exit(void){
 printk(KERN_ALERT "EXIT ultra\n");
 unregister_chrdev(DEV_NUM,DEV_NAME);
  //파일 형식으로 있는 것을 빼낸다(숫자, 이름)
  //fs.h 라이브러리에 있다.
}

module_init(ultra_init);
module_exit(ultra_exit);
// #include <linux/module.h>에서 사용하는 친구들이다. 
// insmod, rmmod에 사용된다. 