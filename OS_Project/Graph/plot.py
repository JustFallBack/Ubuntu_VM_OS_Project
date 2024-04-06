# plot.py

# This script retrieves data from the SQLite database, writes it to a CSV file, and generates graphs using Gnuplot.

import sqlite3
import csv
import subprocess
import os

GRAPH_DIR = "/OS_Project/Graph" # Fill in the path to the directory to OS_Project.
DATABASE = "/OS_Project/main.db" # Fill in the path to the directory to OS_Project.
APACHE_DIR = "/var/www/html"
DATA_CSV = os.path.join(GRAPH_DIR, "data.csv")
GNUPLOT_SCRIPT_CPU = os.path.join(GRAPH_DIR, "gnuplot_script_cpu.gp")
GNUPLOT_SCRIPT_RAM = os.path.join(GRAPH_DIR, "gnuplot_script_ram.gp")
GNUPLOT_SCRIPT_PROCESSES = os.path.join(GRAPH_DIR, "gnuplot_script_processes.gp")

# Connect to the SQLite database.
conn = sqlite3.connect(DATABASE)
cursor = conn.cursor()

# Retrieve dateT, cpu_usage_percentage, ram_usage, and number_of_process data.
cursor.execute('SELECT dateT, cpu_usage_percentage, ram_usage, number_of_process FROM Probe_data ORDER BY dateT ASC')
data = cursor.fetchall()

# Write data to a CSV file.
with open(DATA_CSV, 'w', newline='') as csvfile:
    csvwriter = csv.writer(csvfile)
    csvwriter.writerow(['dateT', 'cpu_usage_percentage', 'ram_usage', 'number_of_process' ])  # Write the header
    csvwriter.writerows(data)

conn.close()

# Gnuplot script templates for CPU usage, RAM usage, and Number of processes.
gnuplot_script_cpu = """
set datafile separator ","
set terminal png
set output '{}'
set title 'CPU Usage Percentage'
set ylabel 'CPU Usage (%)'
unset xlabel  # Disable the display of the x-axis
set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x ''  # Do not display x-axis labels
plot '{}' using 1:2 with lines title ''
""".format("{}/cpu_usage_plot.png".format(APACHE_DIR), DATA_CSV)

gnuplot_script_ram = """
set datafile separator ","
set terminal png
set output '{}'
set title 'RAM Usage'
set ylabel 'RAM Usage (MB)'
unset xlabel  # Disable the display of the x-axis
set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x ''  # Do not display x-axis labels
plot '{}' using 1:3 with lines title ''
""".format("{}/ram_usage_plot.png".format(APACHE_DIR), DATA_CSV)

gnuplot_script_processes = """
set datafile separator ","
set terminal png
set output '{}'
set title 'Number of Processes'
set ylabel 'Number of Processes'
unset xlabel  # Disable the display of the x-axis
set xdata time
set timefmt '%Y-%m-%d %H:%M:%S'
set format x ''  # Do not display x-axis labels
plot '{}' using 1:4 with lines title ''
""".format("{}/processes_plot.png".format(APACHE_DIR), DATA_CSV)

# Write the Gnuplot scripts to temporary files.
with open(GNUPLOT_SCRIPT_CPU, 'w') as script_file:
    script_file.write(gnuplot_script_cpu)

with open(GNUPLOT_SCRIPT_RAM, 'w') as script_file:
    script_file.write(gnuplot_script_ram)

with open(GNUPLOT_SCRIPT_PROCESSES, 'w') as script_file:
    script_file.write(gnuplot_script_processes)

# Execute the Gnuplot scripts to generate images.
subprocess.run(['gnuplot', GNUPLOT_SCRIPT_CPU])
subprocess.run(['gnuplot', GNUPLOT_SCRIPT_RAM])
subprocess.run(['gnuplot', GNUPLOT_SCRIPT_PROCESSES])

# Delete the temporary files.
os.remove(GNUPLOT_SCRIPT_CPU)
os.remove(GNUPLOT_SCRIPT_RAM)
os.remove(GNUPLOT_SCRIPT_PROCESSES)
