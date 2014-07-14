namespace HoardUtils;

class ServerMetrics
{

    protected function getOsName()
    {
        return PHP_OS;
    }

    protected function runCommand(command)
    {
        return trim((string) exec(command));
    }

    protected function getTopSnapshot()
    {
        return this->runCommand("top -l 1 | head -n 10");
    }

    public function getHostName()
    {
        return gethostname();
    }

    public function getLoad()
    {
        var output;
        array matches = [];
        switch this->getOsName() {
            case "Linux":
                let output = this->runCommand("cat /proc/loadavg");
                preg_match_all("/[0-9]+[\\.]{1}[0-9]+/", output, matches);
                return array_map("floatval", matches[0]);
            case "Darwin":
                let output = this->runCommand("sysctl -n vm.loadavg");
                preg_match_all("/[0-9]+[\\.]{1}[0-9]+/", output, matches);
                return array_map("floatval", matches[0]);
        }
    }

    /**
     * Count the number of CPUs available to the system
     * @return {int}
     */
    public function getCpuCount()
    {
        var output;
        switch this->getOsName() {
            case "Linux":
                let output = this->runCommand("cat /proc/cpuinfo | grep processor | wc -l");
                return (int) output;
            case "Darwin":
                let output = this->runCommand("sysctl -n hw.ncpu");
                return (int) output;
        }
    }

    /**
     * Get total memory available to the system
     * @return {int}
     */
    public function getMemoryInfo()
    {
        var output;
        var top;
        array data = [];
        array matches = [];
        let data = [
            "total": 0,
            "used": 0,
            "free": 0
        ];
        switch this->getOsName() {
            case "Darwin":
                let top = this->getTopSnapshot();
                preg_match("/PhysMem: ([0-9]+)M used \\(([0-9]+)M wired\\), ([0-9]+)M unused/", top, matches);
                let output = this->runCommand("sysctl -n hw.memsize");
                let data = [
                    "total": round((int) output / 1024 / 1024, 2),
                    "used": round((int) matches[1], 2),
                    "free": round((int) matches[3], 2)
                ];
                break;
        }
        return data;
    }

}
