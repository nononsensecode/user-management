package arguments

import (
	"flag"
	"fmt"
	"io/ioutil"

	"gopkg.in/yaml.v2"
)

type Config struct {
	Database struct {
		Vendor   string `yaml:"vendor"`
		URL      string `yaml:"url"`
		User     string `yaml:"user"`
		Password string `yaml:"password"`
	} `yaml:"database"`
}

type ConfigError struct {
	Err   error
	Usage func()
}

func (c *ConfigError) Error() string {
	return fmt.Sprintf("%v\n", c.Err)
}

func GetConfiguration() (*Config, error) {
	var configFileFlag string
	const (
		defaultFileName       = "./config.yaml"
		defaultConfigFileDesc = "configuration file for the application"
	)

	flag.StringVar(&configFileFlag, "config", defaultFileName, defaultConfigFileDesc)
	flag.StringVar(&configFileFlag, "c", defaultFileName, defaultConfigFileDesc)

	flag.Parse()

	configFileData, err := ioutil.ReadFile(configFileFlag)
	if err != nil {
		return nil, &ConfigError{
			Err:   fmt.Errorf("configuration file not found: %v", err),
			Usage: flag.CommandLine.Usage,
		}
	}

	var config = Config{}
	err = yaml.Unmarshal(configFileData, &config)
	if err != nil {
		return nil, &ConfigError{
			Err:   fmt.Errorf("configuration syntax error: %v", err),
			Usage: flag.CommandLine.Usage,
		}
	}

	return &config, nil
}
