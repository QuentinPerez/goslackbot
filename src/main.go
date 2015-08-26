package main

import (
	"fmt"

	mod "github.com/QuentinPerez/goslackbot/go_modules"
	"github.com/QuentinPerez/goslackbot/vendor/rainycape/dl"
)

func main() {
	lib, err := dl.Open("c_modules/test.shared", dl.RTLD_NOW)
	if err != nil {
		fmt.Println(err)
		return
	}
	var test func()
	if err := lib.Sym("test", &test); err != nil {
		fmt.Println(err)
		return
	}
	test()
	lib.Close()
	mod.Ls()
}
