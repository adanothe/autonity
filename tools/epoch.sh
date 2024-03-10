#!/bin/bash

# AUT path
AUT=$(which aut)
EPOCH_ID=$($AUT protocol epoch-id)
LAST_EPOCH_BLOCK=$($AUT protocol last-epoch-block)
LAST_BLOCK=$($AUT node info | jq -r '.eth_blockNumber')
NEXT_EPOCH_ID=$((EPOCH_ID + 1))
NEXT_EPOCH_BLOCK=$((LAST_EPOCH_BLOCK + 1800))
TIME_TO_NEXT_EPOCH=$((NEXT_EPOCH_BLOCK - LAST_BLOCK))
MINUTES=$((TIME_TO_NEXT_EPOCH / 60))
SECONDS=$((TIME_TO_NEXT_EPOCH % 60))

echo "current epoch      : $EPOCH_ID"
echo "next epoch         : $NEXT_EPOCH_ID"
echo "time to next epoch : $MINUTES minutes $SECONDS seconds"
echo "last epoch block   : $LAST_EPOCH_BLOCK"
echo "next epoch block   : $NEXT_EPOCH_BLOCK"
echo "last block         : $LAST_BLOCK"
