package main

import (
	"errors"
	"fmt"
	"os"

	"nononsensecode.com/user-management/internal/app/user-mgmt/arguments"
)

func main() {
	config, err := arguments.GetConfiguration()
	if err != nil {
		fmt.Printf("%v\n", err)

		var configErr *arguments.ConfigError
		if errors.As(err, &configErr) {
			configErr.Usage()
		}

		os.Exit(2)
	}

	fmt.Printf("%v\n", *config)
}
