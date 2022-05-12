#!/usr/bin/env python3

import json
import argparse
import os.path

import pytezos


def deploy(tzPath, stgPath, secretPath):
    contract = pytezos.ContractInterface.from_file(tzPath)
    # contract = contract.storage_from_file(stgPath)
    with open(secretPath) as secret_file:
        secret = json.load(secret_file)

    rpc = pytezos.pytezos.using(**secret)

    return rpc.origination(script=contract.script()).autofill().sign().inject(_async=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Contract Deployment Helper')
    parser.add_argument('--contract', type=str, default="./compilation/contract.tz",
                        help='contract file path (default: find the max)')
    parser.add_argument('--init', type=str, default="./compilation/storage.tz",
                        help='storage file path (default: find the max)')
    parser.add_argument('--secret', type=str, default="./.env.json",
                        help='env file path (default: ./.env.json')

    args = parser.parse_args()
    
    print(deploy(os.path.abspath(args.contract),os.path.abspath(args.init),os.path.abspath(args.secret)))
