import argparse
import pandas as pd 

# Define argument parser
parser = argparse.ArgumentParser()
parser.add_argument("--OF", help="operation flag to set", type=str)
parser.add_argument("--CID", help="client ID to set", type=str)
args = parser.parse_args()

df = pd.read_parquet(r'vbep.parquet')

def flag_edit(client_):
    if args.OF:
        df.loc[df['mandt'] == str(client_), 'operation_flag'] = args.OF
        print(f'\n client number {client_} has bee modified 🏠 🛠 with flag {args.OF}\n')

flag_edit(args.CID)
df.to_parquet('vbep_test.parquet', index=False)

