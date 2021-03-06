\name{readCountsData}
\alias{readCountsData}
\title{Convert Accelerometer Output Data to Correct Data Format}

\description{
This function converts accelerometer output data to a correct data format to classify wear and nonwear time using \code{\link{wearingMarking}}. This function can accept accelerometer output data with various epochs (for example, 1-sec, 10-sec or 1-min).
}

\usage{
readCountsData(filename, ctPerSec)
}

\arguments{
\item{filename}{a filename of accelerometer output to be read.}
\item{ctPerSec}{data collection epoch. This argument tells the program the number of counting will be performed in every second. For examples: for 1-sec epoch data, set ctPerSec = 1; for 10-sec epoch data, set ctPerSec = 1/10; for 1-min epoch data, set ctPerSec = 1/60.}
}

\value{
data with the correct format (TimeStamp, counts) to be used for \code{\link{wearingMarking}}.
}

\references{Choi, L., Liu, Z., Matthews, C. E. and Buchowski, M. S.  (2010). Validation of Accelerometer Wear and Nonwear Time Classification Algorithm. Med Sci Sports Exerc. Jun 23 [Epub ahead of print].}

\author{Zhouwen Liu <zhouwen.liu@Vanderbilt.Edu>}

\note{
Warning: It can be very slow if accelerometer data were collected with 1-sec epoch for many days.
}

\seealso{
\code{\link{wearingMarking}}
}

\examples{

###############################################################################
## Read accelerometer output and convert to correct format (TimeStamp, counts).
## As example, "rawActigraphOutput.dat" is an Actigraph output with header:
###############################################################################
## --- Data File Created By ActiGraph GT1M ActiLife v4.4.1 Firmware v7.2.0 ---
## Serial Number: LYN2B21080027
## Start Time 16:15:00
## Start Date 6/16/2010
## Epoch Period (hh:mm:ss) 00:00:01
## Download Time 09:50:23
## Download Date 6/22/2010
## Current Memory Address: 983038
## Current Battery Voltage: 4.01     Mode = 0
## --------------------------------------------------
###############################################################################
## This raw data with 1-sec epoch can be converted to a correct data format to
## classify wear and nonwear time using "wearingMarking" by the following code:

\dontrun{mydata1s = readCountsData("rawActigraphOutput.dat", ctPerSec=1)}

}
