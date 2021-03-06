\name{wearingMarking}
\alias{wearingMarking}

\title{Classify Wear and Nonwear Time for Accelerometer Data}
\description{
This function classifies wear and nonwear time status for accelerometer data by epoch-by-epoch basis.}

\usage{
wearingMarking(dataset, frame = 90,  perMinuteCts = 60, TS = "TimeStamp", 
cts = "counts", streamFrame = NULL, allowanceFrame = 2, newcolname = "wearing", 
getMinuteMarking = FALSE, dayStart = "00:00:00", dayEnd = "23:59:59", ...)
}

\arguments{
  \item{dataset}{the source dataset, in dataframe format, which needs to be marked.}
  \item{frame}{the size of time interval to be considered; Window 1 described in Choi, L., Liu, Z., Matthews, C. E. and Buchowski, M. S. (2010). The default is 90.}
  \item{perMinuteCts}{the number of data rows per minute. The default is 1-sec epoch (perMinuteCts = 60). For examples: for data with 10-sec epoch, set perMinuteCts = 6; for data with 1-min epoch, set perMinuteCts = 1.}
  \item{TS}{the column name for timestamp. The default is "TimeStamp".}
  \item{cts}{the column name for counts. The default is "counts".}
  \item{streamFrame}{the size of time interval that the program will look back or forward if activity is detected; Window 2 described in Choi, L., Liu, Z., Matthews, C. E. and Buchowski, M. S. (2010). The default is the half of the frame.}
  \item{allowanceFrame}{the size of time interval that zero counts are allowed; the artifactual movement interval described in Choi, L., Liu, Z., Matthews, C. E. and Buchowski, M. S. (2010). The default is 2.}
  \item{newcolname}{the column name for classified wear and nonwear status. The default is "wearing".  After the data is processed, a new field will be added to the original dataframe.  This new field is the wearing /nowwearing indicator.}
  \item{getMinuteMarking}{return minute data with wear and nonwear classification. If the source is not a minute dataset, the function will collapse it into minute data. The default is FALSE.}
  \item{dayStart}{define the starting time of day. The default is the midnight, "00:00:00". It must be in the format of "hh:mm:ss".}
  \item{dayEnd}{define the ending time of day. The default is "23:59:59". It must be in the format of "hh:mm:ss".}
  \item{\dots}{parameter settings that will be used in \code{\link{dataCollapser}} function.}
}

\details{
A detailed description of the algorithm implemented in this function is described in Choi, L., Liu, Z., Matthews, C. E. and Buchowski, M. S. (2010).
}

\value{
a dataframe with the column for wear and nonwear classification indicator by epoch-by-epoch basis.
}

\references{Choi, L., Liu, Z., Matthews, C. E. and Buchowski, M. S.  (2010). Validation of Accelerometer Wear and Nonwear Time Classification Algorithm. Med Sci Sports Exerc. Jun 23 [Epub ahead of print].}

\author{
Leena Choi <leena.choi@Vanderbilt.Edu>, Zhouwen Liu <zhouwen.liu@Vanderbilt.Edu>, Charles E. Matthews <Charles.Matthews2@nih.gov>, and Maciej S. Buchowski <maciej.buchowski@Vanderbilt.Edu>
}

\note{Warning: It will be very slow if accelerometer data with 1-sec epoch for many days are directly classified. We recommend to collapse a dataset with 1-sec epoch to 1-min epoch data using \code{\link{dataCollapser}} and then classify wear and nonwear status using a dataset with a larger epoch.
}

\seealso{\code{\link{readCountsData}}, \code{\link{sumVct}} }

\examples{

data(dataSec)

## mark data with 1-min epoch
mydata1m = dataCollapser(dataSec, TS = "TimeStamp", col = "counts", by = 60)

data1m = wearingMarking(dataset = mydata1m,
                       frame = 90, 
                       perMinuteCts = 1,
                       TS = "TimeStamp",
                       cts = "counts", 
                       streamFrame = NULL, 
                       allowanceFrame= 2, 
                       newcolname = "wearing")

sumVct(data1m, id="dataid")

## mark data with 1-sec epoch
\dontrun{
data1s = wearingMarking(dataset = dataSec,
                       frame = 90, 
                       perMinuteCts = 60,
                       TS = "TimeStamp",
                       cts = "counts", 
                       streamFrame = NULL, 
                       allowanceFrame= 2, 
                       newcolname = "wearing",
                       getMinuteMarking = FALSE)

sumVct(data1s, id="dataid")
sumVct(data1s, id="dataid", markingString = "nw")
}

}
