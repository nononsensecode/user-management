package main

import (
	"flag"
	"io/ioutil"

	"gopkg.in/yaml.v2"
)


type Config struct {
	DatabaseUrl string `yaml:"dbUrl"`
}


func main() {
	var config string
	const (
		defaultConfig = "./config.yaml"
		defaultConfigDesc = "configuration file for the application"
	)
	flag.StringVar(&config, "config", defaultConfig, defaultConfigDesc)
	flag.StringVar(&config, "c", defaultConfig, defaultConfigDesc)

	flag.Parse()

	configData := Config{}
	
	configFileData, err := ioutil.ReadFile(config)
	if err != nil {
		panic(err)
	}

	err = yaml.Unmarshal(configFileData, &configData)
	if err != nil {
		panic(err)
	}

}