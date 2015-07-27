`nthOccurance` <-
function(dataVct, value, nth = NA, reverse = FALSE)
{
# dataVct is a vector of boolean values corresponding to whether or not the
#   value in the original vector was > 0 (in the case where value != NA)
# value is ..? true when called by marking.R
# The return value is a list of the indicies which are nonzero
    loc = c()
    if(reverse){
        dataVct = rev(dataVct)
    }

    if(is.na(value)){
        value = "NA"
        dataVct[is.na(dataVct)] = "NA"
    }

    # temp = list of ascending numbers from 1 up to and including the length of
    # dataVct.
    temp = 1:length(dataVct)
    # in the default case where nth = NA the length is equal to 1
    if(length(nth)==1){
        if( is.na(nth)){
            # loc is now a vector of all the indicies where there is a nonzero
            # value.
            # let dataVct = [TRUE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE]
            # then loc = [1, 2, 3, 6]
            loc = temp[match(dataVct, value, nomatch = 0)==1]
        }else{
            # This appears to only match on the indicies indicated by nth
            # whereas above it matches against the entire vector
            loc = temp[match(dataVct, value, nomatch = 0)==1][nth]
        }
    }else{
        # I'm not sure what happens in this case
        loc = temp[match(dataVct, value, nomatch = 0)==1][nth]
    }

    if(reverse){ 
        loc = length(dataVct) - loc +1
    }

    if(sum(is.na(loc)) == length(loc)){
        loc = 0
    }

    return(loc)
}

