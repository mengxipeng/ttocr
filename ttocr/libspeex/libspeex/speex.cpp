// test.cpp : 定义控制台应用程序的入口点。
//

#include <stdio.h>
#include "stdlib.h"
#include "string.h"

#include "../speex-1.2rc1/include/speex/speex.h"

#ifdef WIN32
	extern "C" { FILE _iob[3] = {__iob_func()[0], __iob_func()[1], __iob_func()[2]}; }
#endif

#define FRAME_SIZE 320

int encode(char* pInputData, int inputLen, char* pOuputData, int outputLen)
{
	float input[FRAME_SIZE];
	char cbits[100];
	int nbBytes;

	SpeexBits bits;

	void *state = speex_encoder_init(&speex_wb_mode);

	int sampleRate = 16000;
	speex_encoder_ctl(state,SPEEX_SET_SAMPLING_RATE,&sampleRate);

	int quality=7;
	speex_encoder_ctl(state, SPEEX_SET_QUALITY, &quality);

	speex_bits_init(&bits);

	int count = 0;

	int packetSize = FRAME_SIZE*2;
	for (int i = 0; i < inputLen; i = i + packetSize)
	{
		int leftSize = inputLen - i;

		for (int j=0;j<packetSize&&j<leftSize;j=j+2) 
		{
			short f = *((short*)(pInputData+i+j));

			input[j/2] = f;
		}
	
		if (packetSize > leftSize) 
		{
			for (int j=leftSize;j<packetSize;j=j+2)
				input[j/2]=0;
		}

		speex_bits_reset(&bits);
		speex_encode(state, input, &bits);

		nbBytes = speex_bits_write(&bits, cbits, 100);
		
		(*(pOuputData+count)) = (char)nbBytes;
		count++;
		memcpy(pOuputData+count, cbits, nbBytes);
		count += nbBytes;
	}

	speex_encoder_destroy(state);
	speex_bits_destroy(&bits);

	return count;

}


int decode(char* pInputData, int inputLen, char* pOuputData, int outputLen)
{
	float output[FRAME_SIZE];
	char cbits[100];

	SpeexBits bits;

	void *state = speex_decoder_init(&speex_wb_mode);

	int sampleRate = 16000;
	speex_decoder_ctl(state,SPEEX_SET_SAMPLING_RATE,&sampleRate);

	int enh=1;
	speex_decoder_ctl(state, SPEEX_SET_ENH, &enh);


	speex_bits_init(&bits);

	int count = 0;

	for (int i = 0; i < inputLen; i = i++)
	{
		int packetSize = pInputData[i];

		//int leftSize = inputLen - i;

        printf("%s\n", pInputData+i+1);
        
		memcpy(cbits,pInputData+i+1,packetSize);

		speex_bits_read_from(&bits, cbits, packetSize);

		speex_decode(state, &bits, output);

		for (int j=0;j<FRAME_SIZE;j++) 
		{
			short f = *(output+j);
			(*(short*)(pOuputData+count)) = f;
			count = count+2;
		}

		i += packetSize;
	}

	speex_decoder_destroy(state);
	speex_bits_destroy(&bits);

	return count;

}

