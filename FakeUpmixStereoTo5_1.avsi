# Create fake 5.1 from stereo for testing Downmix6Stereo
Function FakeUpmixStereoTo5_1(clip a)
{
    a = a.ConvertAudioToFloat()          # safer for mixing

    # Split original stereo
    L = GetChannel(a, 1)                 # Left
    R = GetChannel(a, 2)                 # Right

    # Center: mono (L+R) at -3 dB
    C = MixAudio(L, R, 0.5, 0.5)

    # LFE: mono (L+R) at lower level (no low-pass, just reduced volume)
    LFE = MixAudio(L, R, 0.25, 0.25)     # -6 dB vs center

    # Surrounds: delayed, slightly lower level copies of L/R
    SL = DelayAudio(L, 0.02).Amplify(0.7)  # ~20 ms delay
    SR = DelayAudio(R, 0.02).Amplify(0.7)

    # Merge to 6 channels: FL, FR, FC, LFE, SL, SR
    return MergeChannels(L, R, C, LFE, SL, SR)
}
