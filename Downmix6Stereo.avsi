#============================================================
#  Downmix6Stereo.avsi
#------------------------------------------------------------
#  Description:
#    Downmixes 6-channel (5.1) audio to stereo.
#    The mix levels for Center, Surround, and LFE channels
#    can be adjusted via parameters.
#
#  Usage:
#    Downmix6Stereo(clip a [, float "center_gain", float "surround_gain", float "lfe_gain"])
#
#  Parameters:
#    center_gain   - Gain applied to Center channel (default 0.7071)
#    surround_gain - Gain applied to Surround channels (default 0.7071)
#    lfe_gain      - Gain applied to LFE channel (default 0.0)
#
#  Typical example:
#    AudioDub(VideoClip, Downmix6Stereo(AudioClip))
#
#  Compatibility:
#    - AviSynth+ 3.4 and later (32-bit and 64-bit)
#    - Classic AviSynth 2.6 (and the MT build)
#    - Not compatible with AviSynth versions older than 2.5.8
#
#  Notes:
#    • Function uses only core AviSynth functions (no plugins required).
#    • Input must contain 6 discrete audio channels in the order:
#         FL, FR, FC, LFE, SL, SR
#
#  Author:
#    CluelessCoder73
#
#============================================================

Function Downmix6Stereo(clip a, float "center_gain", float "surround_gain", float "lfe_gain")
{
    center_gain  = Default(center_gain,  0.7071)
    surround_gain = Default(surround_gain, 0.7071)
    lfe_gain     = Default(lfe_gain,     0.0)

    FL = GetChannel(a, 1) # Front Left
    FR = GetChannel(a, 2) # Front Right
    FC = GetChannel(a, 3) # Front Center
    LFE = GetChannel(a, 4) # LFE
    SL = GetChannel(a, 5) # Surround Left
    SR = GetChannel(a, 6) # Surround Right

    # Build Left channel:
    LeftMix = MixAudio(FL, FC, 1.0, center_gain)
    LeftMix = MixAudio(LeftMix, SL, 1.0, surround_gain)
    LeftMix = MixAudio(LeftMix, LFE, 1.0, lfe_gain)

    # Build Right channel:
    RightMix = MixAudio(FR, FC, 1.0, center_gain)
    RightMix = MixAudio(RightMix, SR, 1.0, surround_gain)
    RightMix = MixAudio(RightMix, LFE, 1.0, lfe_gain)

    return MergeChannels(LeftMix, RightMix)
}
